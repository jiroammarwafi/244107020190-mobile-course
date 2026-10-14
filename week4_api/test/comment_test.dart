import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  // Memastikan semua field yang hilang diisi nilai default tanpa gagal parse.
  test('Comment.fromJson uses defaults when fields are missing', () {
    final comment = Comment.fromJson(const {});

    expect(comment.postId, 0);
    expect(comment.id, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });

  // Memastikan nilai null dan tipe yang salah juga tidak membuat parsing gagal.
  test('Comment.fromJson handles nulls and unexpected field types', () {
    final comment = Comment.fromJson({
      'postId': null,
      'id': 'not-an-integer',
      'name': null,
      'email': 42,
      'body': false,
    });

    expect(comment.postId, 0);
    expect(comment.id, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });
}
