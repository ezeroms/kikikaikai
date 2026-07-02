import 'package:audio_service/audio_service.dart';
import 'package:kikikaikai/core/media/kikikaikai_media_handler.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_engagement.dart';

/// カード上の再生進捗を、保存済みデータとライブ再生状態から組み立てる。
abstract final class ContentPlaybackProgressResolver {
  /// 再生ハンドラの現在位置を反映した進捗を返す。
  /// 別コンテンツを再生中、または state が無い場合は saved をそのまま返す。
  static ContentPlaybackProgress? resolveLiveProgress({
    required KikikaikaiMediaHandler? handler,
    required String contentId,
    required ContentPlaybackProgress? savedProgress,
    required PlaybackState? playbackState,
  }) {
    if (handler == null || handler.currentContent?.id != contentId) {
      return savedProgress;
    }
    if (playbackState == null) return savedProgress;

    final mediaDuration = handler.mediaItem.value?.duration;
    final durationMs = mediaDuration != null && mediaDuration.inMilliseconds > 0
        ? mediaDuration.inMilliseconds
        : savedProgress?.durationMs;
    final positionMs = playbackState.updatePosition.inMilliseconds;
    final completed = playbackState.processingState ==
            AudioProcessingState.completed ||
        savedProgress?.completed == true ||
        _isNearlyComplete(positionMs, durationMs);

    return ContentPlaybackProgress(
      positionMs: positionMs,
      durationMs: durationMs,
      completed: completed,
    );
  }

  /// 表示用の最終進捗。保存データが無いときは未再生として 0 から始める。
  static ContentPlaybackProgress resolveDisplayProgress({
    required KikikaikaiMediaHandler? handler,
    required String contentId,
    required ContentPlaybackProgress? savedProgress,
    required PlaybackState? playbackState,
    required Content content,
  }) {
    final liveProgress = resolveLiveProgress(
      handler: handler,
      contentId: contentId,
      savedProgress: savedProgress,
      playbackState: playbackState,
    );

    if (liveProgress != null) return liveProgress;

    return ContentPlaybackProgress(
      positionMs: 0,
      durationMs: content.playbackDuration?.inMilliseconds,
    );
  }

  static bool _isNearlyComplete(int positionMs, int? durationMs) {
    if (durationMs == null || durationMs <= 0) return false;
    return positionMs >= (durationMs * 0.95).round();
  }

  /// 保存済み進捗から再生再開位置を返す。完聴済みは先頭から。
  static Duration? resumePosition(ContentPlaybackProgress? saved) {
    if (saved == null || saved.completed || saved.positionMs <= 0) {
      return null;
    }
    return Duration(milliseconds: saved.positionMs);
  }
}
