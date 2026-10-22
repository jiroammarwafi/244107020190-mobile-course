import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/models/post.dart';
import 'package:week5_offline_notes/data/providers.dart';
import 'package:week5_offline_notes/data/repositories/posts_repository.dart';

class _FakePostsRepository extends PostsRepository {
  _FakePostsRepository()
    : super(
        dio: Dio(),
        openDb: () => throw UnsupportedError('The test must not open SQLite'),
      );

  final cachedPost = const Post(
    userId: 1,
    id: 1,
    title: 'Cached',
    body: 'From SQLite',
  );
  final latestPost = const Post(
    userId: 1,
    id: 2,
    title: 'Fresh',
    body: 'From the API',
  );
  final events = <String>[];
  final fetchStarted = Completer<void>();
  final response = Completer<List<Post>>();
  final saved = Completer<void>();

  @override
  Future<List<Post>> readCachedPosts() async {
    events.add('cache');
    return [cachedPost];
  }

  @override
  Future<List<Post>> fetchPosts() {
    events.add('fetch');
    fetchStarted.complete();
    return response.future;
  }

  @override
  Future<void> savePosts(List<Post> posts) async {
    events.add('save');
    saved.complete();
  }
}

void main() {
  test(
    'returns cached posts before fetching and then refreshes the cache',
    () async {
      final repository = _FakePostsRepository();
      final container = ProviderContainer(
        overrides: [postsRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final initial = await container.read(postsProvider.future);
      expect(initial.posts.single.title, 'Cached');
      await repository.fetchStarted.future;
      expect(repository.events, ['cache', 'fetch']);

      repository.response.complete([repository.latestPost]);
      await repository.saved.future;
      await Future<void>.delayed(Duration.zero);

      final refreshed = container.read(postsProvider).requireValue;
      expect(repository.events, ['cache', 'fetch', 'save']);
      expect(refreshed.posts.single.title, 'Fresh');
    },
  );
}
