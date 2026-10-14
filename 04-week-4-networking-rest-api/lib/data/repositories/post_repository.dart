import 'package:dio/dio.dart';

import '../models/post.dart';

/// Owns HTTP requests and converts JSON responses into post models.
class PostRepository {
  const PostRepository(this._dio);

  final Dio _dio;

  /// Fetches one server-paginated batch of posts.
  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) async {
    final response = await _dio.get<List<dynamic>>(
      '/posts',
      queryParameters: {'_page': page, '_limit': limit},
    );
    final data = response.data ?? const <dynamic>[];
    return data.whereType<Map<String, dynamic>>().map(Post.fromJson).toList();
  }
}
