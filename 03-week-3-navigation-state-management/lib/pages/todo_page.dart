import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredTodos = ref.watch(filteredTodoListProvider);
    final allTodos = ref.watch(todoListProvider);
    final activeFilter = ref.watch(todoFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo Riverpod'),
        actions: [
          PopupMenuButton<TodoFilter>(
            initialValue: activeFilter,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter tugas',
            onSelected: (filter) =>
                ref.read(todoFilterProvider.notifier).setFilter(filter),
            itemBuilder: (context) => const [
              PopupMenuItem(value: TodoFilter.all, child: Text('Semua')),
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
                final originalIndex = allTodos.indexOf(todo);

                return TodoTile(
                  title: todo.title,
                  isCompleted: todo.done,
                  onToggle: (_) {
                    if (originalIndex != -1) {
                      ref.read(todoListProvider.notifier).toggle(originalIndex);
                    }
                  },
                  onDelete: () {
                    if (originalIndex != -1) {
                      ref.read(todoListProvider.notifier).remove(originalIndex);
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
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tugas baru'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nama tugas...'),
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
