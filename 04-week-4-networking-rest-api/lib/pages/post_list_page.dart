import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/network_errors.dart';
import '../data/paged_posts.dart';

/// Displays paged posts and maps every list state to an appropriate UI.
class PostListPage extends ConsumerStatefulWidget {
  const PostListPage({super.key});

  @override
  ConsumerState<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends ConsumerState<PostListPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 240) {
      ref.read(pagedPostsProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pagedPostsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API Posts'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: () =>
                ref.read(pagedPostsProvider.notifier).loadFirstPage(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(PagedPostsState state) {
    if (state.error != null && state.items.isEmpty) {
      return _ErrorState(
        message: friendlyErrorMessage(state.error!),
        onRetry: () => ref.read(pagedPostsProvider.notifier).loadFirstPage(),
      );
    }
    if (state.isLoadingFirstPage && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!state.isLoadingFirstPage && state.items.isEmpty) {
      return const Center(child: Text('Belum ada data dari server.'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(pagedPostsProvider.notifier).loadFirstPage(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.items.length + 1,
        itemBuilder: (context, index) {
          if (index < state.items.length) {
            final post = state.items[index];
            return ListTile(
              leading: CircleAvatar(child: Text('${post.id}')),
              title: Text(post.title),
              subtitle: Text(
                post.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }

          if (state.error != null) {
            return _LoadMoreError(
              message: friendlyErrorMessage(state.error!),
              onRetry: () =>
                  ref.read(pagedPostsProvider.notifier).loadNextPage(),
            );
          }
          if (!state.hasMore) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('Semua data telah dimuat.')),
            );
          }
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}

class _LoadMoreError extends StatelessWidget {
  const _LoadMoreError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}
