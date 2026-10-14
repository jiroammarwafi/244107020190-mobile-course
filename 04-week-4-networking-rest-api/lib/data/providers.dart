import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'repositories/post_repository.dart';

/// Shared Dio client keeps HTTP configuration in one place.
final dioProvider = Provider<Dio>((ref) => createDio());

/// Repository is injected so tests can replace it without making HTTP calls.
final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(dioProvider)),
);
