import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({required this.noteId, super.key});

  final int noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Membaca langsung dari repository lokal SQLite melalui singleNoteProvider
    final noteAsync = ref.watch(singleNoteProvider(noteId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
      ),
      body: noteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat catatan: $error'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => ref.invalidate(singleNoteProvider(noteId)),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (note) {
          if (note == null) {
            return const Center(child: Text('Catatan tidak ditemukan'));
          }

          final isDirty = note.dirty;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              note.title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDirty
                                  ? Colors.amber.withValues(alpha: 0.2)
                                  : Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDirty
                                    ? Colors.amber.shade700
                                    : Colors.green.shade600,
                              ),
                            ),
                            child: Text(
                              isDirty ? 'belum tersinkron' : 'tersinkron',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDirty
                                    ? Colors.amber.shade900
                                    : Colors.green.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ID Catatan: #${note.id}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const Divider(height: 24),
                      Text(
                        note.body.isEmpty
                            ? '(Catatan tidak memiliki isi teks)'
                            : note.body,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Terakhir Diperbarui'),
                subtitle: Text(note.updatedAt.toIso8601String()),
              ),
              ListTile(
                leading: Icon(
                  isDirty ? Icons.sync_problem : Icons.cloud_done,
                  color: isDirty ? Colors.amber.shade800 : Colors.green.shade700,
                ),
                title: const Text('Status Sinkronisasi'),
                subtitle: Text(
                  isDirty
                      ? 'Belum tersinkron ke server (Local dirty)'
                      : 'Tersinkron dengan server',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
