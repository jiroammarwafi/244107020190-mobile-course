import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/repositories/post_repository.dart';
import 'package:week4_api/main.dart';
import 'package:week4_api/pages/paged_post_page.dart';

/// Repository palsu menghindari request jaringan saat menguji tampilan aplikasi.
class _FakePostRepository extends PostRepository {
  _FakePostRepository({
    this.posts,
    this.failFirstPage = false,
    this.pendingFirstPage,
  }) : super(Dio());

  final post = const Post(
    userId: 1,
    id: 7,
    title: 'Judul lengkap',
    body: 'Isi lengkap post untuk halaman detail.',
  );
  final List<Post>? posts;
  final Completer<List<Post>>? pendingFirstPage;
  bool failFirstPage;
  var fetchPostCalls = 0;

  @override
  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) async {
    if (page == 1 && pendingFirstPage != null) {
      return pendingFirstPage!.future;
    }
    if (failFirstPage) {
      failFirstPage = false;
      throw DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );
    }
    return posts ?? [post];
  }

  @override
  Future<Post> fetchPost(int id) async {
    fetchPostCalls++;
    return post;
  }
}

void main() {
  testWidgets('shows loading until the first page arrives', (tester) async {
    final response = Completer<List<Post>>();
    final repository = _FakePostRepository(pendingFirstPage: response);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [postRepositoryProvider.overrideWith((ref) => repository)],
        child: const MaterialApp(home: PagedPostPage()),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    response.complete([repository.post]);
    await tester.pumpAndSettle();

    expect(find.text('Judul lengkap'), findsOneWidget);
  });

  testWidgets('opens complete post detail from the paged list', (tester) async {
    final repository = _FakePostRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [postRepositoryProvider.overrideWith((ref) => repository)],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Posts Paged'), findsOneWidget);
    expect(find.text('Semua data termuat.'), findsOneWidget);
    await tester.tap(find.text('Judul lengkap'));
    await tester.pumpAndSettle();

    expect(find.text('Judul lengkap'), findsOneWidget);
    expect(find.text('Isi lengkap post untuk halaman detail.'), findsOneWidget);
    expect(repository.fetchPostCalls, 0);
  });

  testWidgets('shows a successful empty state when no posts are returned', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWith(
            (ref) => _FakePostRepository(posts: const []),
          ),
        ],
        child: const MaterialApp(home: PagedPostPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum ada data dari server.'), findsOneWidget);
    expect(find.text('Semua data termuat.'), findsNothing);
  });

  testWidgets('shows an error and retries the initial page', (tester) async {
    final repository = _FakePostRepository(failFirstPage: true);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [postRepositoryProvider.overrideWith((ref) => repository)],
        child: const MaterialApp(home: PagedPostPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Tidak dapat terhubung ke server'),
      findsOneWidget,
    );
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Judul lengkap'), findsOneWidget);
    expect(find.text('Tidak dapat terhubung ke server'), findsNothing);
  });
}
