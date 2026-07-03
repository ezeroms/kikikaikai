import 'package:kikikaikai/core/media/media_playback.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_type.dart';

/// 概要・コメント欄のタイムスタンプタップから再生位置を移動する。
abstract final class MediaTimestampSeek {
  MediaTimestampSeek._();

  static bool isSupported(Content content) =>
      content.mediaUrl != null &&
      (content.type.isAudioPlayback || content.type == ContentType.video);

  static Future<void> seek(
    Content content,
    Duration position, {
    Duration? previewLimit,
  }) async {
    if (!isSupported(content)) return;

    await MediaPlayback.init();
    final handler = MediaPlayback.handler;
    if (handler == null) return;

    if (handler.currentContent?.id == content.id) {
      if (!handler.playingNotifier.value) {
        handler.preparePlaybackAt(position);
      }
      await handler.seek(position);
      if (!handler.playingNotifier.value) {
        await handler.play();
      }
      return;
    }

    await MediaPlayback.playContent(
      content,
      startPosition: position,
      previewLimit: previewLimit,
    );
  }
}
