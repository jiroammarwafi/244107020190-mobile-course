import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Ambil daftar yang sudah difilter oleh provider turunan
    final filteredTodos = ref.watch(filteredTodoListProvider);
    // 2. Ambil list asli untuk mencari index asli saat toggle/remove
    final allTodos = ref.watch(todoListProvider);
    // 3. Status filter yang sedang aktif
    final activeFilter = ref.watch(todoFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo Riverpod'),
        actions: [
          // Dropdown / menu pilihan filter
          PopupMenuButton<TodoFilter>(
            initialValue: activeFilter,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Tugas',
            onSelected: (filter) {
              // Kode baru:
              ref.read(todoFilterProvider.notifier).setFilter(filter);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: TodoFilter.all,
                child: Text('Semua'),
              ),
              PopupMenuItem(
                value: TodoFilter.active,
                child: Text('Belum Selesai'),
              ),
              PopupMenuItem(
                value: TodoFilter.completed,
                child: Text('Selesai'),
              ),
            ],
          ),
        ],
      ),
      body: filteredTodos.isEmpty
          ? const Center(child: Text('Tidak ada tugas'))
          : ListView.builder(
              itemCount: filteredTodos.length,
              itemBuilder: (context, index) {
                final todo = filteredTodos[index];
                // Cari index asli item ini di list utama agar toggle/remove tepat sasaran
                final originalIndex = allTodos.indexOf(todo);

                // Menggunakan widget terpisah TodoTile (Tugas 1)
                return TodoTile(
                  title: todo.title,
                  isCompleted: todo.done,
                  onToggle: (_) {
                    if (originalIndex != -1) {
                      ref
                          .read(todoListProvider.notifier)
                          .toggle(originalIndex);
                    }
                  },
                  onDelete: () {
                    if (originalIndex != -1) {
                      ref
                          .read(todoListProvider.notifier)
                          .remove(originalIndex);
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tugas baru'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nama tugas...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                ref.read(todoListProvider.notifier).add(text);
              }
              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}