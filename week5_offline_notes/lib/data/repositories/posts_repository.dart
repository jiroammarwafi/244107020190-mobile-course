import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../local/db.dart';
import '../models/post.dart';

class PostsRepository {
  PostsRepository({required this.dio, Future<Database> Function()? openDb})
    : _openDb = openDb ?? openNotesDb;

  final Dio dio;
  final Future<Database> Function() _openDb;

  Future<List<Post>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    return rows.map((row) {
      final payload = jsonDecode(row['payload'] as String);
      if (payload is! Map<String, dynamic>) {
        throw const FormatException(
          'Cached post payload must be a JSON object',
        );
      }
      return Post.fromJson(payload);
    }).toList();
  }

  Future<List<Post>> fetchPosts() async {
    final response = await dio.get<List<dynamic>>('/posts');
    final data = response.data;
    if (data == null) {
      throw const FormatException(
        'The posts endpoint returned no response data',
      );
    }
    return data.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException(
          'A post response item is not a JSON object',
        );
      }
      return Post.fromJson(item);
    }).toList();
  }

  Future<void> savePosts(List<Post> posts) async {
    final db = await _openDb();
    final cachedAt = DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      await txn.delete('cached_posts');
      for (final post in posts) {
        await txn.insert('cached_posts', {
          'id': post.id,
          'payload': jsonEncode(post.toJson()),
          'cached_at': cachedAt,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }
}
