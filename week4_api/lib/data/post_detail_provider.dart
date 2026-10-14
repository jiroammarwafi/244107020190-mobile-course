import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'paged_posts.dart';
import 'models/post.dart';
import 'providers.dart';

/// Loads a post from the already-initialized list or directly from the API.
class PostDetailNotifier extends AsyncNotifier<Post> {
  PostDetailNotifier(this.postId);

  /// The ID supplied through [postDetailProvider].
  final int postId;

  @override
  Future<Post> build() async {
    if (ref.exists(pagedPostsProvider)) {
      for (final post in ref.read(pagedPostsProvider).items) {
        if (post.id == postId) return post;
      }
    }

    if (ref.exists(postListProvider)) {
      final posts = ref.read(postListProvider).asData?.value;
      for (final post in posts ?? const <Post>[]) {
        if (post.id == postId) return post;
      }
    }

    return ref.read(postRepositoryProvider).fetchPost(postId);
  }
}

/// Family provider keeps detail state isolated for each post ID.
final postDetailProvider =
    AsyncNotifierProvider.family<PostDetailNotifier, Post, int>(
      PostDetailNotifier.new,
      retry: (retryCount, error) => null,
    );
