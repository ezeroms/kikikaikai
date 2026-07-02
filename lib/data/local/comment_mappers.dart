import 'package:kikikaikai/core/models/content_comment.dart';
import 'package:kikikaikai/data/dummy/dummy_comments.dart';

abstract final class CommentMappers {
  static ContentComment fromRow(Map<String, Object?> row) {
    return ContentComment(
      id: row['id']! as String,
      body: row['body']! as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at']! as int),
      authorName: row['author_name']! as String,
      authorAvatarAsset: row['author_avatar_asset'] as String?,
    );
  }

  static Map<String, Object?> seedToRow(DummyCommentSeed seed) {
    return {
      'id': seed.id,
      'content_id': seed.contentId,
      'author_name': seed.authorName,
      'author_avatar_asset': seed.authorAvatarAsset,
      'body': seed.body,
      'created_at': seed.createdAt.millisecondsSinceEpoch,
      'is_seed': 1,
    };
  }

  static Map<String, Object?> userCommentToRow({
    required String id,
    required String contentId,
    required String body,
    required DateTime createdAt,
    String authorName = '匿名',
    String? authorAvatarAsset,
  }) {
    return {
      'id': id,
      'content_id': contentId,
      'author_name': authorName,
      'author_avatar_asset': authorAvatarAsset,
      'body': body,
      'created_at': createdAt.millisecondsSinceEpoch,
      'is_seed': 0,
    };
  }
}
