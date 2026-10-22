import 'dart:async';

import 'repositories/note_repository.dart';

Future<int> syncNotes(
  NoteRepository repository, {
  Duration simulatedServerDelay = const Duration(seconds: 1),
}) async {
  final dirtyCount = await repository.countDirty();
  if (dirtyCount == 0) return 0;

  await Future<void>.delayed(simulatedServerDelay);
  await repository.markAllSynced();
  return dirtyCount;
}
