import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/models/post.dart';
import 'package:week5_offline_notes/data/providers.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/data/repositories/posts_repository.dart';
import 'package:week5_offline_notes/main.dart';

class _FakeNoteRepository extends NoteRepository {
  _FakeNoteRepository() : super(openDb: _unusedDb);

  static Future<Database> _unusedDb() =>
      throw UnsupportedError('The test must not open SQLite');

  @override
  Future<List<Note>> fetchNotes() async => [];
}

class _FakePostsRepository extends PostsRepository {
  _FakePostsRepository() : super(dio: Dio(), openDb: _unusedDb);

  static Future<Database> _unusedDb() =>
      throw UnsupportedError('The test must not open SQLite');

  @override
  Future<List<Post>> readCachedPosts() async => [];

  @override
  Future<List<Post>> fetchPosts() async => [];

  @override
  Future<void> savePosts(List<Post> posts) async {}
}

void main() {
  testWidgets('shows the tabs and toggles deterministic offline mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          noteRepositoryProvider.overrideWithValue(_FakeNoteRepository()),
          postsRepositoryProvider.overrideWithValue(_FakePostsRepository()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Posts API'), findsOneWidget);
    expect(find.text('Catatan'), findsNWidgets(2));
    expect(find.text('Mode online aktif'), findsOneWidget);
    await tester.tap(find.byKey(const Key('forceOfflineSwitch')));
    await tester.pumpAndSettle();
    expect(find.text('Mode offline aktif'), findsOneWidget);

    await tester.tap(find.text('Catatan').first);
    await tester.pumpAndSettle();
    expect(
      find.text('Belum ada catatan. Tambahkan catatan baru.'),
      findsOneWidget,
    );
  });
}
