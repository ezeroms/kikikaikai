import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:kikikaikai/core/media/content_playback_progress_resolver.dart';
import 'package:kikikaikai/core/media/media_playback.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_engagement.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/core/models/user_tier.dart';
import 'package:kikikaikai/features/content/widgets/fullscreen_video_page.dart';

abstract final class ContentCardPlayback {
  static bool isPlayable(Content content, UserTier tier) {
    if (content.mediaUrl == null) return false;
    if (content.type != ContentType.video && !content.type.isAudioPlayback) {
      return false;
    }
    if (tier.canAccess(content.accessLevel)) return true;
    return content.type == ContentType.video || content.type.isAudioPlayback;
  }

  /// カード上に再生ボタンを出すか（動画は詳細画面から再生）
  static bool showsCardPlayButton(Content content, UserTier tier) {
    if (content.type == ContentType.video) return false;
    return isPlayable(content, tier);
  }

  static Duration? previewLimit(Content content, UserTier tier) {
    if (tier.canAccess(content.accessLevel)) return null;
    if (content.type == ContentType.video || content.type.isAudioPlayback) {
      return const Duration(seconds: 30);
    }
    return null;
  }

  static Future<void> play(
    BuildContext context, {
    required Content content,
    required UserTier tier,
    ContentPlaybackProgress? savedProgress,
  }) async {
    if (!isPlayable(content, tier)) return;

    try {
      await MediaPlayback.playContent(
        content,
        previewLimit: previewLimit(content, tier),
        startPosition: ContentPlaybackProgressResolver.resumePosition(
          savedProgress,
        ),
      );
    } catch (_) {
      rethrow;
    }

    if (!context.mounted || content.type != ContentType.video) return;

    final controller = MediaPlayback.handler?.videoControllerNotifier.value;
    if (controller == null) return;

    await openFullscreenVideo(
      context,
      controller: controller,
      title: content.title,
    );
  }

  /// カード上の再生ボタン — 再生中なら一時停止、同曲停止中なら再開、それ以外は再生
  static Future<void> toggle(
    BuildContext context, {
    required Content content,
    required UserTier tier,
    ContentPlaybackProgress? savedProgress,
  }) async {
    if (!isPlayable(content, tier)) return;

    final handler = MediaPlayback.handler;
    if (handler == null) {
      await play(
        context,
        content: content,
        tier: tier,
        savedProgress: savedProgress,
      );
      return;
    }

    final isCurrent = handler.currentContent?.id == content.id;
    if (isCurrent) {
      final state = handler.playbackState.valueOrNull;
      final playing = state?.playing ?? false;
      final loading = state?.processingState == AudioProcessingState.loading ||
          state?.processingState == AudioProcessingState.buffering;

      if (playing) {
        await handler.pause();
        return;
      }
      // 読み込み中の再タップは無視（stop が走ると Operation Stopped になる）
      if (loading) {
        return;
      }
      await handler.play();
      return;
    }

    try {
      await play(
        context,
        content: content,
        tier: tier,
        savedProgress: savedProgress,
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('音声の読み込みに失敗しました。アプリを再起動してください。'),
          ),
        );
      }
    }
  }
}
