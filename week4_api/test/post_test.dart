import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/network_errors.dart';
import 'package:week4_api/data/post_detail_provider.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/repositories/post_repository.dart';

class FakePostRepository extends PostRepository {
  FakePostRepository({this.items, this.throwError = false, this.detailPost})
    : super(Dio());

  final List<Post>? items;
  final bool throwError;
  final Post? detailPost;
  var fetchPostCalls = 0;

  @override
  Future<List<Post>> fetchPosts() async {
    if (throwError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );
    }
    return items ?? const [];
  }

  @override
  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) async {
    return fetchPosts();
  }

  @override
  Future<Post> fetchPost(int id) async {
    fetchPostCalls++;
    if (throwError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/posts/$id'),
        type: DioExceptionType.connectionError,
      );
    }
    return detailPost ??
        const Post(userId: 1, id: 99, title: 'Detail', body: 'Isi lengkap');
  }
}

void main() {
  test('fromJson aman terhadap field yang hilang', () {
    final post = Post.fromJson({'id': 7});
    expect(post.id, 7);
    expect(post.title, '');
    expect(post.userId, 0);
  });

  test('friendlyErrorMessage untuk connection error', () {
    final err = DioException(
      requestOptions: RequestOptions(path: '/posts'),
      type: DioExceptionType.connectionError,
    );
    expect(friendlyErrorMessage(err), contains('terhubung'));
  });

  test('provider sukses dengan repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        postRepositoryProvider.overrideWithValue(
          FakePostRepository(
            items: [const Post(userId: 1, id: 1, title: 'Tes', body: 'Isi')],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    // Gunakan helper readPostsOnce (lihat providers.dart).
    final posts = await readPostsOnce(container);
    expect(posts.length, 1);
    expect(posts.first.title, 'Tes');
  });

  test('provider error dengan repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        postRepositoryProvider.overrideWithValue(
          FakePostRepository(throwError: true),
        ),
      ],
    );
    addTearDown(container.dispose);
    // Gunakan helper readPostsErrorOnce (lihat providers.dart).
    final err = await readPostsErrorOnce(container);
    expect(err, isA<DioException>());
    expect(friendlyErrorMessage(err!), contains('terhubung'));
  });

  test('detail memakai repository jika post list belum dibuka', () async {
    final repository = FakePostRepository(
      detailPost: const Post(
        userId: 1,
        id: 8,
        title: 'Langsung dibuka',
        body: 'Isi detail',
      ),
    );
    final container = ProviderContainer(
      overrides: [postRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final post = await container.read(postDetailProvider(8).future);

    expect(post.title, 'Langsung dibuka');
    expect(repository.fetchPostCalls, 1);
  });

  test('detail menggunakan post list yang sudah dimuat', () async {
    final repository = FakePostRepository(
      items: [
        const Post(userId: 1, id: 8, title: 'Dari list', body: 'Isi cached'),
      ],
    );
    final container = ProviderContainer(
      overrides: [postRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(postListProvider.future);
    final post = await container.read(postDetailProvider(8).future);

    expect(post.title, 'Dari list');
    expect(repository.fetchPostCalls, 0);
  });
}
