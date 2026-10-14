import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:networking_rest_api/data/models/post.dart';
import 'package:networking_rest_api/data/providers.dart';
import 'package:networking_rest_api/data/repositories/post_repository.dart';
import 'package:networking_rest_api/main.dart';

class _FakePostRepository extends PostRepository {
  _FakePostRepository({this.posts, this.failFirstRequest = false})
    : super(Dio());

  final List<Post>? posts;
  bool failFirstRequest;

  @override
  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) async {
    if (failFirstRequest) {
      failFirstRequest = false;
      throw DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );
    }
    return posts ??
        const [Post(userId: 1, id: 1, title: 'Judul post', body: 'Isi post')];
  }
}

void main() {
  testWidgets('shows loaded posts and the end-of-data state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWith((ref) => _FakePostRepository()),
        ],
        child: const PostsApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Judul post'), findsOneWidget);
    expect(find.text('Semua data telah dimuat.'), findsOneWidget);
  });

  testWidgets('shows an empty state for a successful empty response', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWith(
            (ref) => _FakePostRepository(posts: const []),
          ),
        ],
        child: const PostsApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum ada data dari server.'), findsOneWidget);
  });

  testWidgets('shows a friendly error and retries successfully', (
    tester,
  ) async {
    final repository = _FakePostRepository(failFirstRequest: true);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [postRepositoryProvider.overrideWith((ref) => repository)],
        child: const PostsApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Tidak dapat terhubung'), findsOneWidget);
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Judul post'), findsOneWidget);
  });
}
