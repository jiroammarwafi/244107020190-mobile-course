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

  @override
  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) async {
    return [];
  }
}

void main() {
  testWidgets('app displays the paged posts screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWith((ref) => _FakePostRepository()),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.text('Posts Paged'), findsOneWidget);
  });
}
