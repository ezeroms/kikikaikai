import 'package:kikikaikai/core/models/access_level.dart';
import 'package:kikikaikai/core/models/content_type.dart';

class Content {
  const Content({
    required this.id,
    required this.type,
    required this.accessLevel,
    required this.title,
    required this.description,
    required this.figureIds,
    required this.publishedAt,
    this.thumbnailAsset,
    this.mediaUrl,
    this.bodyMarkdown,
    this.previewDuration = const Duration(seconds: 30),
    this.mediaDuration,
    this.externalUrl,
    this.cardSubtitle,
  });

  final String id;
  final ContentType type;
  final AccessLevel accessLevel;
  final String title;
  final String description;
  final List<String> figureIds;
  final DateTime publishedAt;
  final String? thumbnailAsset;
  final String? mediaUrl;
  final String? bodyMarkdown;
  final Duration previewDuration;
  final Duration? mediaDuration;
  final String? externalUrl;

  /// カード上にタイトル下へ表示するサブテキスト（null ならタイトルのみ）
  final String? cardSubtitle;

  String get displayThumbnail => thumbnailAsset ?? type.iconAsset;

  /// 音声の総尺（カード表示用。未設定時はサンプル既定値）
  Duration? get playbackDuration =>
      mediaDuration ??
      (type.isAudioPlayback ? const Duration(minutes: 42) : null);
}
