import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:networking_rest_api/data/models/post.dart';
import 'package:networking_rest_api/data/network_errors.dart';

void main() {
  group('Post.fromJson', () {
    test('defaults fields that are missing, null, or have wrong types', () {
      final post = Post.fromJson({
        'userId': null,
        'id': 'invalid',
        'title': 42,
        'body': null,
      });

      expect(post.userId, 0);
      expect(post.id, 0);
      expect(post.title, '');
      expect(post.body, '');
    });
  });

  group('friendlyErrorMessage', () {
    test('explains a connection failure', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );

      expect(friendlyErrorMessage(error), contains('terhubung'));
    });

    test('maps a server timeout to a retry message', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.receiveTimeout,
      );

      expect(friendlyErrorMessage(error), contains('timeout'));
      expect(friendlyErrorMessage(error), contains('coba lagi'));
    });
  });
}
