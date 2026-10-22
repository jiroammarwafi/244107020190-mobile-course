import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'local/note.dart';
import 'models/post.dart';
import 'repositories/note_repository.dart';
import 'repositories/posts_repository.dart';
import 'sync_notes.dart';

final dioProvider = Provider<Dio>((ref) => createDio());

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepository(),
);

final postsRepositoryProvider = Provider<PostsRepository>(
  (ref) => PostsRepository(dio: ref.watch(dioProvider)),
);

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
);

final postsProvider = AsyncNotifierProvider<PostsNotifier, PostsFeedState>(
  PostsNotifier.new,
);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() => ref.watch(noteRepositoryProvider).fetchNotes();

  Future<void> addNote({required String title, String body = ''}) async {
    final repository = ref.read(noteRepositoryProvider);
    await repository.addNote(title: title, body: body);
    state = AsyncData(await repository.fetchNotes());
  }

  Future<void> updateNote(Note note) async {
    final repository = ref.read(noteRepositoryProvider);
    await repository.updateNote(note);
    state = AsyncData(await repository.fetchNotes());
  }

  Future<void> deleteNote(int id) async {
    final repository = ref.read(noteRepositoryProvider);
    await repository.deleteNote(id);
    state = AsyncData(await repository.fetchNotes());
  }

  Future<int> sync() async {
    final repository = ref.read(noteRepositoryProvider);
    final syncedCount = await syncNotes(repository);
    state = AsyncData(await repository.fetchNotes());
    return syncedCount;
  }
}

class PostsFeedState {
  const PostsFeedState({
    this.posts = const [],
    this.isRefreshing = false,
    this.refreshError,
  });

  final List<Post> posts;
  final bool isRefreshing;
  final String? refreshError;
}

class PostsNotifier extends AsyncNotifier<PostsFeedState> {
  @override
  Future<PostsFeedState> build() async {
    final repository = ref.watch(postsRepositoryProvider);
    final cached = await repository.readCachedPosts();
    unawaited(_refreshInBackground(repository));
    return PostsFeedState(posts: cached, isRefreshing: true);
  }

  Future<void> refresh() async {
    final current = state.asData?.value;
    if (current == null || current.isRefreshing) return;
    state = AsyncData(PostsFeedState(posts: current.posts, isRefreshing: true));
    await _fetchAndCache(ref.read(postsRepositoryProvider));
  }

  Future<void> _refreshInBackground(PostsRepository repository) async {
    await _fetchAndCache(repository);
  }

  Future<void> _fetchAndCache(PostsRepository repository) async {
    try {
      final latest = await repository.fetchPosts();
      await repository.savePosts(latest);
      state = AsyncData(PostsFeedState(posts: latest));
    } catch (error) {
      final current = state.asData?.value;
      if (current == null) return;
      state = AsyncData(
        PostsFeedState(posts: current.posts, refreshError: error.toString()),
      );
    }
  }
}
