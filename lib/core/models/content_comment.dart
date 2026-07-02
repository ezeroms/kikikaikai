class ContentComment {
  const ContentComment({
    required this.id,
    required this.body,
    required this.createdAt,
    this.authorName = '匿名',
    this.authorAvatarAsset,
  });

  final String id;
  final String body;
  final DateTime createdAt;
  final String authorName;
  final String? authorAvatarAsset;

  Map<String, dynamic> toJson() => {
        'id': id,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'authorName': authorName,
        if (authorAvatarAsset != null)
          'authorAvatarAsset': authorAvatarAsset,
      };

  factory ContentComment.fromJson(Map<String, dynamic> json) {
    return ContentComment(
      id: json['id'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      authorName: json['authorName'] as String? ?? '匿名',
      authorAvatarAsset: json['authorAvatarAsset'] as String?,
    );
  }
}
