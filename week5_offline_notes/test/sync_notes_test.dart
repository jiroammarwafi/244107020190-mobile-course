import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/data/sync_notes.dart';

class _FakeNoteRepository extends NoteRepository {
  _FakeNoteRepository(this.dirtyCount) : super(openDb: _unusedDb);

  static Future<Database> _unusedDb() =>
      throw UnsupportedError('The test must not open SQLite');

  int dirtyCount;
  bool markedSynced = false;

  @override
  Future<int> countDirty() async => dirtyCount;

  @override
  Future<void> markAllSynced() async {
    markedSynced = true;
    dirtyCount = 0;
  }
}

void main() {
  test('does not simulate an upload when no notes are dirty', () async {
    final repository = _FakeNoteRepository(0);

    final synced = await syncNotes(
      repository,
      simulatedServerDelay: Duration.zero,
    );

    expect(synced, 0);
    expect(repository.markedSynced, isFalse);
  });

  test(
    'marks dirty notes synced after the simulated server response',
    () async {
      final repository = _FakeNoteRepository(3);

      final synced = await syncNotes(
        repository,
        simulatedServerDelay: Duration.zero,
      );

      expect(synced, 3);
      expect(repository.markedSynced, isTrue);
      expect(repository.dirtyCount, 0);
    },
  );
}
