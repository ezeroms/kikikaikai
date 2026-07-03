import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/media/content_playback_progress_resolver.dart';
import 'package:kikikaikai/core/media/format_media_duration.dart';
import 'package:kikikaikai/core/media/kikikaikai_media_handler.dart';
import 'package:kikikaikai/core/media/media_playback.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/features/content/widgets/fullscreen_video_page.dart';
import 'package:kikikaikai/shared/widgets/circular_media_button.dart';
import 'package:kikikaikai/shared/widgets/inline_video_play_button.dart';
import 'package:video_player/video_player.dart';

class TvPlayerWidget extends ConsumerStatefulWidget {
  const TvPlayerWidget({
    super.key,
    required this.content,
    this.previewLimit,
    this.showHeaderText = false,
    this.margin = const EdgeInsets.symmetric(vertical: 16),
    this.edgeToEdge = false,
  });

  final Content content;
  final Duration? previewLimit;

  /// プレイヤー内に種別ラベル・タイトルを表示する（詳細画面では外側に出す）
  final bool showHeaderText;
  final EdgeInsetsGeometry margin;

  /// 詳細画面上部向け — 枠線・角丸なしで横幅いっぱい
  final bool edgeToEdge;

  @override
  ConsumerState<TvPlayerWidget> createState() => _TvPlayerWidgetState();
}

class _TvPlayerWidgetState extends ConsumerState<TvPlayerWidget> {
  bool _startingPlayback = false;

  Future<void> _startPlayback() async {
    if (_startingPlayback) return;

    setState(() => _startingPlayback = true);

    try {
      final savedProgress = ref
          .read(contentEngagementProvider)
          .valueOrNull
          ?.playbackFor(widget.content.id);
      await MediaPlayback.playContent(
        widget.content,
        previewLimit: widget.previewLimit,
        startPosition: ContentPlaybackProgressResolver.resumePosition(
          savedProgress,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _startingPlayback = false);
      }
    }
  }

  Future<void> _openFullscreenVideo() async {
    final controller = MediaPlayback.handler?.videoControllerNotifier.value;
    if (controller == null || !mounted) return;
    await openFullscreenVideo(
      context,
      controller: controller,
      title: widget.content.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final handler = MediaPlayback.handler;
    if (handler == null) {
      return _buildPlayer(context, handler: null, isActive: false);
    }

    return ValueListenableBuilder<Content?>(
      valueListenable: handler.currentContentNotifier,
      builder: (context, current, _) {
        final isActive = current?.id == widget.content.id;
        return _buildPlayer(
          context,
          handler: handler,
          isActive: isActive,
        );
      },
    );
  }

  Widget _buildPlayer(
    BuildContext context, {
    required KikikaikaiMediaHandler? handler,
    required bool isActive,
  }) {
    final controlsPadding = widget.edgeToEdge
        ? const EdgeInsets.fromLTRB(20, 16, 20, 0)
        : const EdgeInsets.all(16);

    final player = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
          if (!isActive)
            GestureDetector(
              onTap: _startingPlayback ? null : _startPlayback,
              behavior: HitTestBehavior.opaque,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      widget.content.displayThumbnail,
                      fit: BoxFit.cover,
                    ),
                    ColoredBox(
                      color: Colors.black.withValues(alpha: 0.35),
                    ),
                    Center(
                      child: InlineVideoPlayButton(
                        onPressed:
                            _startingPlayback ? null : _startPlayback,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (handler != null)
            ValueListenableBuilder<VideoPlayerController?>(
              valueListenable: handler.videoControllerNotifier,
              builder: (context, controller, _) {
                if (controller == null || !controller.value.isInitialized) {
                  return AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          widget.content.displayThumbnail,
                          fit: BoxFit.cover,
                        ),
                        ColoredBox(
                          color: Colors.black.withValues(alpha: 0.45),
                        ),
                        const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return InlineVideoPlayer(
                  controller: controller,
                  title: widget.content.title,
                  onFullscreenTap: _openFullscreenVideo,
                );
              },
            ),
          if (widget.showHeaderText || (isActive && !widget.edgeToEdge))
            Padding(
              padding: controlsPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.showHeaderText) ...[
                    Text(
                      widget.content.type.label,
                      style: AppTypography.overline(),
                    ),
                    Text(
                      widget.content.title,
                      style: AppTypography.titleSmall(size: 14),
                    ),
                  ],
                  if (isActive) ...[
                    if (widget.showHeaderText) const SizedBox(height: 12),
                    if (handler != null)
                      ValueListenableBuilder<bool>(
                        valueListenable: handler.previewExpiredNotifier,
                        builder: (context, previewExpired, _) {
                          if (previewExpired) {
                            return Text(
                              'プレビューは30秒までです',
                              style: AppTypography.label(
                                color: AppColors.primary,
                              ),
                            );
                          }
                          return StreamBuilder<PlaybackState>(
                            stream: handler.playbackState,
                            builder: (context, stateSnapshot) {
                              final playing =
                                  stateSnapshot.data?.playing ?? false;
                              final position =
                                  stateSnapshot.data?.updatePosition ??
                                      Duration.zero;
                              final total = handler
                                      .videoControllerNotifier
                                      .value
                                      ?.value
                                      .duration ??
                                  Duration.zero;
                              final progress = total.inMilliseconds > 0
                                  ? position.inMilliseconds /
                                      total.inMilliseconds
                                  : 0.0;
                              return Column(
                                children: [
                                  Slider(
                                    value: progress.clamp(0.0, 1.0),
                                    onChanged: total.inMilliseconds > 0
                                        ? (v) {
                                            handler.seek(
                                              Duration(
                                                milliseconds: (total
                                                            .inMilliseconds *
                                                        v)
                                                    .round(),
                                              ),
                                            );
                                          }
                                        : null,
                                    activeColor: AppColors.primary,
                                    inactiveColor: AppColors.muted,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formatMediaDuration(position),
                                        style: AppTypography.caption(size: 11),
                                      ),
                                      Text(
                                        formatMediaDuration(total),
                                        style: AppTypography.caption(size: 11),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        iconSize: 36,
                                        onPressed: () => handler.seek(
                                          position - const Duration(seconds: 10),
                                        ),
                                        icon: const Icon(
                                          Icons.replay_10_rounded,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                      CircularMediaButton.control(
                                        playing: playing,
                                        onPressed: () {
                                          if (playing) {
                                            handler.pause();
                                          } else {
                                            handler.play();
                                          }
                                        },
                                      ),
                                      IconButton(
                                        iconSize: 36,
                                        onPressed: () => handler.seek(
                                          position + const Duration(seconds: 10),
                                        ),
                                        icon: const Icon(
                                          Icons.forward_10_rounded,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                      IconButton(
                                        iconSize: 36,
                                        onPressed: _openFullscreenVideo,
                                        icon: const Icon(
                                          LucideIcons.maximize,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                  ],
                ],
              ),
            ),
        ],
    );

    if (widget.edgeToEdge) {
      return player;
    }

    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: player,
    );
  }
}
