import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/repositories/post_repository.dart';
import 'package:week4_api/main.dart';

/// Repository palsu menghindari request jaringan saat menguji tampilan aplikasi.
class _FakePostRepository extends PostRepository {
  _FakePostRepository() : super(Dio());

  final post = const Post(
    userId: 1,
    id: 7,
    title: 'Judul lengkap',
    body: 'Isi lengkap post untuk halaman detail.',
  );
  var fetchPostCalls = 0;

  @override
  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) async {
    return [post];
  }

  @override
  Future<Post> fetchPost(int id) async {
    fetchPostCalls++;
    return post;
  }
}

void main() {
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
    await tester.tap(find.text('Judul lengkap'));
    await tester.pumpAndSettle();

    expect(find.text('Judul lengkap'), findsOneWidget);
    expect(find.text('Isi lengkap post untuk halaman detail.'), findsOneWidget);
    expect(repository.fetchPostCalls, 0);
  });
}
