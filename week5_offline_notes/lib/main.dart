import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/local/note.dart';
import 'data/providers.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline Notes',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.teal)),
      home: const NotesHomePage(),
    );
  }
}

class NotesHomePage extends ConsumerWidget {
  const NotesHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Offline Notes'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.article_outlined), text: 'Posts API'),
              Tab(icon: Icon(Icons.note_alt_outlined), text: 'Catatan'),
            ],
          ),
          actions: [
            notes.when(
              data: (items) => IconButton(
                key: const Key('syncNotesButton'),
                tooltip: 'Sinkronkan catatan',
                onPressed: items.any((note) => note.dirty)
                    ? () => _syncNotes(context, ref)
                    : null,
                icon: const Icon(Icons.cloud_upload_outlined),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (error, stackTrace) => IconButton(
                tooltip: 'Muat ulang catatan',
                onPressed: () => ref.invalidate(notesProvider),
                icon: const Icon(Icons.refresh),
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            const PostsTab(),
            NotesTab(
              notes: notes,
              onEdit: (note) => _editNote(context, ref, note: note),
              onDelete: (note) => _deleteNote(context, ref, note),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          key: const Key('addNoteButton'),
          onPressed: () => _editNote(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Catatan'),
        ),
      ),
    );
  }

  Future<void> _syncNotes(BuildContext context, WidgetRef ref) async {
    try {
      final count = await ref.read(notesProvider.notifier).sync();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count catatan berhasil disinkronkan')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sinkronisasi gagal: $error')));
    }
  }

  Future<void> _editNote(
    BuildContext context,
    WidgetRef ref, {
    Note? note,
  }) async {
    final titleController = TextEditingController(text: note?.title ?? '');
    final bodyController = TextEditingController(text: note?.body ?? '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note == null ? 'Catatan baru' : 'Edit catatan'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('noteTitleField'),
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Isi judul' : null,
              ),
              TextFormField(
                key: const Key('noteBodyField'),
                controller: bodyController,
                decoration: const InputDecoration(labelText: 'Isi catatan'),
                minLines: 1,
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            key: const Key('saveNoteButton'),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context, (
                titleController.text.trim(),
                bodyController.text.trim(),
              ));
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    titleController.dispose();
    bodyController.dispose();

    if (result == null) return;
    try {
      final notifier = ref.read(notesProvider.notifier);
      if (note == null) {
        await notifier.addNote(title: result.$1, body: result.$2);
      } else {
        await notifier.updateNote(
          note.copyWith(
            title: result.$1,
            body: result.$2,
            updatedAt: DateTime.now(),
            dirty: true,
          ),
        );
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Catatan gagal disimpan: $error')));
    }
  }

  Future<void> _deleteNote(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) async {
    try {
      await ref.read(notesProvider.notifier).deleteNote(note.id!);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Catatan gagal dihapus: $error')));
    }
  }
}

class PostsTab extends ConsumerWidget {
  const PostsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(postsProvider);

    return feed.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Gagal membaca cache posts: $error'),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => ref.invalidate(postsProvider),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
      data: (value) {
        if (value.posts.isEmpty && value.refreshError != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tidak ada cache dan gagal memuat posts: '
                  '${value.refreshError}',
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => ref.read(postsProvider.notifier).refresh(),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            if (value.isRefreshing) const LinearProgressIndicator(),
            if (value.refreshError != null)
              MaterialBanner(
                content: Text(
                  'Refresh gagal; menampilkan cache. ${value.refreshError}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => ref.read(postsProvider.notifier).refresh(),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(postsProvider.notifier).refresh(),
                child: value.posts.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 180),
                          Center(child: Text('Belum ada posts tersimpan')),
                        ],
                      )
                    : ListView.builder(
                        itemCount: value.posts.length,
                        itemBuilder: (context, index) {
                          final post = value.posts[index];
                          return ListTile(
                            leading: CircleAvatar(child: Text('${post.id}')),
                            title: Text(post.title),
                            subtitle: Text(post.body, maxLines: 2),
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class NotesTab extends ConsumerWidget {
  const NotesTab({
    required this.notes,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final AsyncValue<List<Note>> notes;
  final ValueChanged<Note> onEdit;
  final ValueChanged<Note> onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return notes.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Gagal membaca catatan: $error'),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => ref.invalidate(notesProvider),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
      data: (items) => items.isEmpty
          ? const Center(
              child: Text('Belum ada catatan. Tambahkan catatan baru.'),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final note = items[index];
                return ListTile(
                  key: Key('note-${note.id}'),
                  title: Text(note.title),
                  subtitle: Text(
                    '${note.body.isEmpty ? 'Tanpa isi' : note.body}'
                    '${note.dirty ? ' • Belum disinkronkan' : ' • Tersinkron'}',
                    maxLines: 2,
                  ),
                  onTap: () => onEdit(note),
                  trailing: IconButton(
                    tooltip: 'Hapus catatan',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => onDelete(note),
                  ),
                );
              },
            ),
    );
  }
}
