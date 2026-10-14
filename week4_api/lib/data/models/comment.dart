/// Model komentar JSONPlaceholder; nilai default menjaga parsing aman
/// ketika properti tidak tersedia atau bernilai null.
class Comment {
  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  /// ID post yang memiliki komentar.
  final int postId;

  /// ID unik komentar.
  final int id;

  /// Nama pengirim komentar.
  final String name;

  /// Email pengirim komentar.
  final String email;

  /// Isi komentar.
  final String body;

  /// Membentuk model dari JSON dan memberi nilai default pada field kosong.
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      postId: json['postId'] is num ? (json['postId'] as num).toInt() : 0,
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      name: json['name'] is String ? json['name'] as String : '',
      email: json['email'] is String ? json['email'] as String : '',
      body: json['body'] is String ? json['body'] as String : '',
    );
  }
}
