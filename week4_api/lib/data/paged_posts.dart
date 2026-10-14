import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/post.dart';
import 'providers.dart';

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

class PagedPostsNotifier extends Notifier<PagedPostsState> {
  bool _isLoadingFirstPage = false;

  @override
  PagedPostsState build() {
    Future.microtask(loadFirstPage);
    return const PagedPostsState();
  }

  Future<void> loadFirstPage() async {
    if (_isLoadingFirstPage) return;
    _isLoadingFirstPage = true;
    final repository = ref.read(postRepositoryProvider);
    state = PagedPostsState(
      items: state.items,
      page: state.page,
      isLoadingFirstPage: true,
      hasMore: state.hasMore,
    );
    try {
      final items = await repository.fetchPostsPage(page: 1, limit: 10);
      state = PagedPostsState(
        items: items,
        page: 1,
        isLoadingFirstPage: false,
        hasMore: items.length == 10,
      );
      _isLoadingFirstPage = false;
    } catch (e) {
      state = PagedPostsState(
        items: state.items,
        page: state.page,
        isLoadingFirstPage: false,
        hasMore: state.hasMore,
        error: e,
      );
      _isLoadingFirstPage = false;
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingFirstPage || state.isLoadingMore || !state.hasMore) {
      return;
    }
    final repo = ref.read(postRepositoryProvider);
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
      final next = currentPage + 1;
      final items = await repo.fetchPostsPage(page: next, limit: 10);
      state = PagedPostsState(
        items: [...currentItems, ...items],
        page: next,
        isLoadingFirstPage: false,
        hasMore: items.length == 10,
      );
    } catch (e) {
      state = PagedPostsState(
        items: currentItems,
        page: currentPage,
        isLoadingFirstPage: false,
        hasMore: true,
        error: e,
      );
    }
  }
}

final pagedPostsProvider =
    NotifierProvider<PagedPostsNotifier, PagedPostsState>(
      PagedPostsNotifier.new,
    );
