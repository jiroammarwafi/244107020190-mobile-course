import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:networking_rest_api/data/models/post.dart';
import 'package:networking_rest_api/data/paged_posts.dart';
import 'package:networking_rest_api/data/providers.dart';
import 'package:networking_rest_api/data/repositories/post_repository.dart';

class _FakePostRepository extends PostRepository {
  _FakePostRepository(this.fetchPage) : super(Dio());

  final Future<List<Post>> Function(int page) fetchPage;
  final requestedPages = <int>[];

  @override
  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) {
    requestedPages.add(page);
    return fetchPage(page);
  }
}

List<Post> _posts(int firstId, int count) => List.generate(
  count,
  (index) => Post(
    userId: 1,
    id: firstId + index,
    title: 'Post ${firstId + index}',
    body: 'Body ${firstId + index}',
  ),
);

void main() {
  test('provider loads the first page from an overridden repository', () async {
    final repository = _FakePostRepository((page) async => _posts(1, 3));
    final container = ProviderContainer(
      overrides: [postRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final firstState = Completer<PagedPostsState>();
    final subscription = container.listen(pagedPostsProvider, (_, next) {
      if (!next.isLoadingFirstPage && !firstState.isCompleted) {
        firstState.complete(next);
      }
    }, fireImmediately: true);
    addTearDown(subscription.close);

    final state = await firstState.future;
    expect(state.items, hasLength(3));
    expect(state.items.first.title, 'Post 1');
    expect(repository.requestedPages, [1]);
  });

  test('provider appends pages and prevents overlapping requests', () async {
    final secondPage = Completer<List<Post>>();
    final repository = _FakePostRepository((page) {
      if (page == 1) return Future.value(_posts(1, 10));
      return secondPage.future;
    });
    final container = ProviderContainer(
      overrides: [postRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(pagedPostsProvider, (_, _) {});
    addTearDown(subscription.close);

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(pagedPostsProvider).items, hasLength(10));

    final notifier = container.read(pagedPostsProvider.notifier);
    final firstRequest = notifier.loadNextPage();
    final overlappingRequest = notifier.loadNextPage();
    expect(repository.requestedPages, [1, 2]);

    secondPage.complete(_posts(11, 2));
    await Future.wait([firstRequest, overlappingRequest]);

    final state = container.read(pagedPostsProvider);
    expect(state.items, hasLength(12));
    expect(state.items.map((post) => post.id).toSet(), hasLength(12));
    expect(state.hasMore, isFalse);
  });
}
