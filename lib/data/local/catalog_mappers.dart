import 'package:kikikaikai/core/models/access_level.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/core/models/figure.dart';

/// SQLite 行 ↔ ドメインモデルの変換。
abstract final class CatalogMappers {
  static Figure figureFromRow(Map<String, Object?> row) {
    return Figure(
      id: row['id']! as String,
      name: row['name']! as String,
      sortKey: row['sort_key']! as String,
      bio: row['bio']! as String,
      avatarAsset: row['avatar_asset']! as String,
    );
  }

  static Map<String, Object?> figureToRow(Figure figure) {
    return {
      'id': figure.id,
      'name': figure.name,
      'sort_key': figure.sortKey,
      'bio': figure.bio,
      'avatar_asset': figure.avatarAsset,
    };
  }

  static Content contentFromRow(
    Map<String, Object?> row, {
    required List<String> figureIds,
  }) {
    final mediaDurationMs = row['media_duration_ms'] as int?;
    return Content(
      id: row['id']! as String,
      type: ContentType.values.byName(row['type']! as String),
      accessLevel: AccessLevel.values.byName(row['access_level']! as String),
      title: row['title']! as String,
      description: row['description']! as String,
      figureIds: figureIds,
      publishedAt: DateTime.fromMillisecondsSinceEpoch(
        row['published_at']! as int,
      ),
      thumbnailAsset: row['thumbnail_asset'] as String?,
      mediaUrl: row['media_url'] as String?,
      bodyMarkdown: row['body_markdown'] as String?,
      previewDuration: Duration(
        milliseconds: row['preview_duration_ms']! as int,
      ),
      mediaDuration: mediaDurationMs == null
          ? null
          : Duration(milliseconds: mediaDurationMs),
      externalUrl: row['external_url'] as String?,
      cardSubtitle: row['card_subtitle'] as String?,
    );
  }

  static Map<String, Object?> contentToRow(Content content) {
    return {
      'id': content.id,
      'type': content.type.name,
      'access_level': content.accessLevel.name,
      'title': content.title,
      'description': content.description,
      'published_at': content.publishedAt.millisecondsSinceEpoch,
      'thumbnail_asset': content.thumbnailAsset,
      'media_url': content.mediaUrl,
      'body_markdown': content.bodyMarkdown,
      'preview_duration_ms': content.previewDuration.inMilliseconds,
      'media_duration_ms': content.mediaDuration?.inMilliseconds,
      'external_url': content.externalUrl,
      'card_subtitle': content.cardSubtitle,
    };
  }
}
