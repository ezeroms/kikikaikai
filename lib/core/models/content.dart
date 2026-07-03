import 'package:kikikaikai/core/models/access_level.dart';
import 'package:kikikaikai/core/models/content_media_format.dart';
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
    this.transcript,
    this.mediaFormat,
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

  /// 音声コンテンツの書き起こし
  final String? transcript;

  /// ラジオのメディア形式（音声のみ / 映像付き）。他カテゴリは null。
  final ContentMediaFormat? mediaFormat;

  String get displayThumbnail => thumbnailAsset ?? type.iconAsset;

  /// 詳細画面で街頭テレビと同じレイアウト（映像プレーヤー）を使う
  bool get usesVideoDetailLayout =>
      type == ContentType.video ||
      (type == ContentType.audio &&
          mediaFormat == ContentMediaFormat.audioWithVideo);

  /// 詳細画面で奇奇怪怪と同じ音声プレーヤーヘッダーを使う
  bool get usesAudioDetailLayout =>
      type.isAudioPlayback && !usesVideoDetailLayout;

  /// 詳細画面で「書き起こし」タブを表示する
  bool get hasTranscriptTab => usesAudioDetailLayout;

  /// 音声の総尺（カード表示用。未設定時はサンプル既定値）
  Duration? get playbackDuration =>
      mediaDuration ??
      ((type.isAudioPlayback || usesVideoDetailLayout)
          ? const Duration(minutes: 42)
          : null);
}
