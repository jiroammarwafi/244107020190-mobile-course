import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/comment.dart';
import 'providers.dart' show dioProvider;
import 'repositories/comment_repository.dart';

/// Menyediakan repository komentar menggunakan klien Dio aplikasi.
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

/// Memuat komentar secara async; exception dari build otomatis menjadi
/// AsyncError sehingga UI dapat mengamati error melalui state provider.
class CommentsNotifier extends AsyncNotifier<List<Comment>> {
  /// Menyimpan ID post yang diteruskan oleh family provider.
  CommentsNotifier(this.postId);

  /// ID post untuk request komentar.
  final int postId;

  /// Mengambil komentar berdasarkan ID post saat provider digunakan.
  @override
  Future<List<Comment>> build() {
    return ref.watch(commentRepositoryProvider).fetchComments(postId);
  }
}

/// Provider async komentar; retry dimatikan agar error langsung tersedia
/// sebagai AsyncError dan tidak mengulang request secara otomatis.
final commentsProvider =
    AsyncNotifierProvider.family<CommentsNotifier, List<Comment>, int>(
      CommentsNotifier.new,
      retry: (retryCount, error) => null,
    );

/// Mengubah error jaringan/HTTP menjadi pesan yang mudah dipahami pengguna.
String friendlyCommentErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout. Periksa internet Anda lalu coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      case DioExceptionType.badResponse:
        switch (error.response?.statusCode) {
          case 404:
            return 'Komentar tidak ditemukan (404).';
          case 500:
            return 'Server sedang mengalami gangguan (500). Coba lagi nanti.';
          default:
            return 'Server tidak dapat memproses permintaan. Coba lagi nanti.';
        }
      default:
        return 'Terjadi masalah saat memuat komentar. Coba lagi.';
    }
  }
  return 'Terjadi kesalahan tak terduga saat memuat komentar.';
}
