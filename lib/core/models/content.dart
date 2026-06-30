import 'package:kikikaikai/core/models/access_level.dart';
import 'package:kikikaikai/core/models/content_type.dart';

class Content {
  const Content({
    required this.id,
    required this.type,
    required this.accessLevel,
    required this.title,
    required this.description,
    required this.authorId,
    required this.publishedAt,
    this.thumbnailAsset,
    this.mediaUrl,
    this.bodyMarkdown,
    this.previewDuration = const Duration(seconds: 30),
    this.externalUrl,
  });

  final String id;
  final ContentType type;
  final AccessLevel accessLevel;
  final String title;
  final String description;
  final String authorId;
  final DateTime publishedAt;
  final String? thumbnailAsset;
  final String? mediaUrl;
  final String? bodyMarkdown;
  final Duration previewDuration;
  final String? externalUrl;

  String get displayThumbnail => thumbnailAsset ?? type.iconAsset;
}
