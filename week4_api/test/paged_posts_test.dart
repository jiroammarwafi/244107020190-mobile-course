import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/paged_posts.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/repositories/post_repository.dart';

class _PagedPostRepository extends PostRepository {
  _PagedPostRepository(this.fetchPage) : super(Dio());

  final Future<List<Post>> Function(int page) fetchPage;
  final requestedPages = <int>[];

  @override
  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) {
    requestedPages.add(page);
    return fetchPage(page);
  }
}

Future<PagedPostsState> _waitForState(
  ProviderContainer container,
  bool Function(PagedPostsState state) predicate,
) {
  final completer = Completer<PagedPostsState>();
  final subscription = container.listen(pagedPostsProvider, (previous, next) {
    if (!completer.isCompleted && predicate(next)) completer.complete(next);
  }, fireImmediately: true);
  return completer.future.whenComplete(subscription.close);
}

List<Post> _posts(int start, int count) => List.generate(
  count,
  (index) => Post(
    userId: 1,
    id: start + index,
    title: 'Post ${start + index}',
    body: 'Body ${start + index}',
  ),
);

void main() {
  test(
    'pagination blocks overlapping requests and stops at the last page',
    () async {
      final firstPage = Completer<List<Post>>();
      final secondPage = Completer<List<Post>>();
      final repository = _PagedPostRepository((page) {
        return switch (page) {
          1 => firstPage.future,
          2 => secondPage.future,
          _ => Future.value(const <Post>[]),
        };
      });
      final container = ProviderContainer(
        overrides: [postRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(pagedPostsProvider, (_, _) {});
      addTearDown(subscription.close);

      expect(container.read(pagedPostsProvider).isLoadingFirstPage, isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(repository.requestedPages, [1]);

      await container.read(pagedPostsProvider.notifier).loadNextPage();
      expect(repository.requestedPages, [1]);

      firstPage.complete(_posts(1, 10));
      final firstState = await _waitForState(
        container,
        (state) => state.page == 1 && !state.isLoadingFirstPage,
      );
      expect(firstState.items, hasLength(10));
      expect(firstState.hasMore, isTrue);

      final notifier = container.read(pagedPostsProvider.notifier);
      final requestOne = notifier.loadNextPage();
      final requestTwo = notifier.loadNextPage();
      expect(container.read(pagedPostsProvider).isLoadingMore, isTrue);
      expect(repository.requestedPages, [1, 2]);

      secondPage.complete(_posts(11, 2));
      await Future.wait([requestOne, requestTwo]);

      final finalState = container.read(pagedPostsProvider);
      expect(finalState.items, hasLength(12));
      expect(finalState.items.map((post) => post.id).toSet(), hasLength(12));
      expect(finalState.hasMore, isFalse);

      await notifier.loadNextPage();
      expect(repository.requestedPages, [1, 2]);
    },
  );

  test('empty response finishes loading and reports no more pages', () async {
    final repository = _PagedPostRepository((_) async => const []);
    final container = ProviderContainer(
      overrides: [postRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(pagedPostsProvider, (_, _) {});
    addTearDown(subscription.close);

    final state = await _waitForState(
      container,
      (state) => state.page == 1 && !state.isLoadingFirstPage,
    );

    expect(state.items, isEmpty);
    expect(state.hasMore, isFalse);
    expect(state.error, isNull);
  });

  test('initial error can be retried successfully', () async {
    var attempt = 0;
    final repository = _PagedPostRepository((_) async {
      attempt++;
      if (attempt == 1) throw StateError('temporary failure');
      return _posts(1, 1);
    });
    final container = ProviderContainer(
      overrides: [postRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(pagedPostsProvider, (_, _) {});
    addTearDown(subscription.close);

    final errorState = await _waitForState(
      container,
      (state) => state.error != null && !state.isLoadingFirstPage,
    );
    expect(errorState.items, isEmpty);

    final retry = container.read(pagedPostsProvider.notifier).loadFirstPage();
    final successFuture = _waitForState(
      container,
      (state) => state.page == 1 && !state.isLoadingFirstPage,
    );
    await retry;
    final success = await successFuture;

    expect(success.items, hasLength(1));
    expect(success.error, isNull);
    expect(attempt, 2);
  });
}
