import 'dart:async';

import 'models/post.dart';
import 'repositories/note_repository.dart';
import 'repositories/posts_repository.dart';

Future<int> syncNotes(
  NoteRepository repository, {
  Duration simulatedServerDelay = const Duration(seconds: 1),
}) async {
  final dirtyCount = await repository.countDirty();
  if (dirtyCount == 0) return 0;

  await Future<void>.delayed(simulatedServerDelay);
  await repository.markAllSynced();
  return dirtyCount;
}

class PostsSyncService {
  const PostsSyncService(this.repository);

  final PostsRepository repository;

  Future<List<Post>> loadCache() => repository.readCachedPosts();

  Future<List<Post>> fetchAndCache() async {
    final latest = await repository.fetchPosts();
    await repository.savePosts(latest);
    return latest;
  }
}
