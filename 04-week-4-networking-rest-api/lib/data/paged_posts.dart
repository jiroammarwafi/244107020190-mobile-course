import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/post.dart';
import 'providers.dart';

/// UI state for initial loading, pagination, errors, and completed results.
class PagedPostsState {
  const PagedPostsState({
    this.items = const [],
    this.page = 0,
    this.isLoadingFirstPage = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  final List<Post> items;
  final int page;
  final bool isLoadingFirstPage;
  final bool isLoadingMore;
  final bool hasMore;
  final Object? error;
}

/// Coordinates paged requests and prevents concurrent calls for a page.
class PagedPostsNotifier extends Notifier<PagedPostsState> {
  bool _isLoadingFirstPage = false;

  @override
  PagedPostsState build() {
    Future.microtask(loadFirstPage);
    return const PagedPostsState();
  }

  /// Loads or retries the first server page.
  Future<void> loadFirstPage() async {
    if (_isLoadingFirstPage) return;
    _isLoadingFirstPage = true;
    state = PagedPostsState(
      items: state.items,
      page: state.page,
      isLoadingFirstPage: true,
      hasMore: state.hasMore,
    );

    try {
      final posts = await ref
          .read(postRepositoryProvider)
          .fetchPostsPage(page: 1, limit: 10);
      state = PagedPostsState(
        items: posts,
        page: 1,
        isLoadingFirstPage: false,
        hasMore: posts.length == 10,
      );
    } catch (error) {
      state = PagedPostsState(
        items: state.items,
        page: state.page,
        isLoadingFirstPage: false,
        hasMore: state.hasMore,
        error: error,
      );
    } finally {
      _isLoadingFirstPage = false;
    }
  }

  /// Appends the next page; overlapping calls are ignored.
  Future<void> loadNextPage() async {
    if (state.isLoadingFirstPage || state.isLoadingMore || !state.hasMore) {
      return;
    }

    final currentItems = state.items;
    final currentPage = state.page;
    state = PagedPostsState(
      items: currentItems,
      page: currentPage,
      isLoadingFirstPage: false,
      isLoadingMore: true,
      hasMore: state.hasMore,
    );

    try {
      final posts = await ref
          .read(postRepositoryProvider)
          .fetchPostsPage(page: currentPage + 1, limit: 10);
      state = PagedPostsState(
        items: [...currentItems, ...posts],
        page: currentPage + 1,
        isLoadingFirstPage: false,
        hasMore: posts.length == 10,
      );
    } catch (error) {
      state = PagedPostsState(
        items: currentItems,
        page: currentPage,
        isLoadingFirstPage: false,
        hasMore: true,
        error: error,
      );
    }
  }
}

/// Application-wide paged posts state.
final pagedPostsProvider =
    NotifierProvider<PagedPostsNotifier, PagedPostsState>(
      PagedPostsNotifier.new,
    );
