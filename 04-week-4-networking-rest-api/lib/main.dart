import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/post_list_page.dart';

void main() {
  runApp(const ProviderScope(child: PostsApp()));
}

/// Root widget provides app theme and the posts screen.
class PostsApp extends StatelessWidget {
  const PostsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'REST API Posts',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const PostListPage(),
    );
  }
}
