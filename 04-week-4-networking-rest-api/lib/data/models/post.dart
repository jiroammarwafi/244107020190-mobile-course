/// A post returned by JSONPlaceholder.
class Post {
  const Post({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  final int userId;
  final int id;
  final String title;
  final String body;

  /// Parses known fields while defaulting missing, null, or wrongly typed data.
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'] is num ? (json['userId'] as num).toInt() : 0,
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      title: json['title'] is String ? json['title'] as String : '',
      body: json['body'] is String ? json['body'] as String : '',
    );
  }
}
