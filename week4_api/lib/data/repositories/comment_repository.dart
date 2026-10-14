import 'package:dio/dio.dart';

import '../models/comment.dart';

/// Mengambil komentar post dari JSONPlaceholder melalui Dio.
class CommentRepository {
  CommentRepository(this._dio);

  /// Klien HTTP yang dibagikan aplikasi.
  final Dio _dio;

  /// Meminta komentar untuk [postId] dengan batas waktu 10 detik.
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List<dynamic>>(
      '/comments',
      queryParameters: {'postId': postId},
    );

    // Abaikan item yang bentuknya bukan object JSON dan parse object lainnya.
    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
