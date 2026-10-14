import 'package:dio/dio.dart';

/// Maps Dio failures to short, user-friendly messages.
String friendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout. Periksa internet Anda lalu coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) return 'Data tidak ditemukan (404).';
        if (statusCode == 500) {
          return 'Server sedang mengalami gangguan (500). Coba lagi nanti.';
        }
        return 'Server tidak dapat memproses permintaan. Coba lagi nanti.';
      default:
        return 'Terjadi masalah saat memuat data. Coba lagi.';
    }
  }
  return 'Terjadi kesalahan tak terduga. Coba lagi.';
}
