import 'package:flutter/material.dart';

import '../data/models/post.dart';

/// Displays a post in a compact, reusable list row.
class PostTile extends StatelessWidget {
  const PostTile({
    required this.post,
    this.onTap,
    this.showBody = true,
    super.key,
  });

  /// The post displayed by this row.
  final Post post;

  /// Called when the user selects the row.
  final VoidCallback? onTap;

  /// Whether to show a shortened preview of the post body.
  final bool showBody;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(child: Text(post.id.toString())),
      title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: showBody
          ? Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis)
          : null,
    );
  }
}
