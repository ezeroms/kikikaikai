import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/media/media_playback.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/features/content/widgets/fullscreen_video_page.dart';
import 'package:video_player/video_player.dart';

class TvPlayerWidget extends ConsumerStatefulWidget {
  const TvPlayerWidget({
    super.key,
    required this.content,
    this.previewLimit,
  });

  final Content content;
  final Duration? previewLimit;

  @override
  ConsumerState<TvPlayerWidget> createState() => _TvPlayerWidgetState();
}

class _TvPlayerWidgetState extends ConsumerState<TvPlayerWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MediaPlayback.playContent(
        widget.content,
        previewLimit: widget.previewLimit,
      );
    });
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final handler = MediaPlayback.handler;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (handler != null)
            ValueListenableBuilder<VideoPlayerController?>(
              valueListenable: handler.videoControllerNotifier,
              builder: (context, controller, _) {
                if (controller == null || !controller.value.isInitialized) {
                  return AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ColoredBox(
                      color: AppColors.darkSurface,
                      child: Image.asset(
                        widget.content.displayThumbnail,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  );
                }
                return InlineVideoPlayer(
                  controller: controller,
                  title: widget.content.title,
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '街頭テレビ',
                  style: AppTypography.label(color: AppColors.mangoTango),
                ),
                Text(
                  widget.content.title,
                  style: AppTypography.body(size: 14),
                ),
                const SizedBox(height: 12),
                if (handler != null)
                  ValueListenableBuilder<bool>(
                    valueListenable: handler.previewExpiredNotifier,
                    builder: (context, previewExpired, _) {
                      if (previewExpired) {
                        return Text(
                          'プレビューは30秒までです',
                          style: AppTypography.label(
                            color: AppColors.mangoTango,
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
                              ? position.inMilliseconds / total.inMilliseconds
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
                                activeColor: AppColors.mangoTango,
                                inactiveColor: AppColors.shuttleGray,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(position),
                                    style: AppTypography.label(size: 11),
                                  ),
                                  Text(
                                    _formatDuration(total),
                                    style: AppTypography.label(size: 11),
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
                                      position - const Duration(seconds: 15),
                                    ),
                                    icon: const Icon(
                                      LucideIcons.rotate_ccw,
                                      color: AppColors.summerWood,
                                    ),
                                  ),
                                  IconButton(
                                    iconSize: 52,
                                    onPressed: () {
                                      if (playing) {
                                        handler.pause();
                                      } else {
                                        handler.play();
                                      }
                                    },
                                    icon: Icon(
                                      playing
                                          ? LucideIcons.pause
                                          : LucideIcons.play,
                                      color: AppColors.mangoTango,
                                    ),
                                  ),
                                  IconButton(
                                    iconSize: 36,
                                    onPressed: () => handler.seek(
                                      position + const Duration(seconds: 15),
                                    ),
                                    icon: const Icon(
                                      LucideIcons.rotate_cw,
                                      color: AppColors.summerWood,
                                    ),
                                  ),
                                  IconButton(
                                    iconSize: 36,
                                    onPressed: () {
                                      final controller = handler
                                          .videoControllerNotifier.value;
                                      if (controller != null &&
                                          controller.value.isInitialized) {
                                        openFullscreenVideo(
                                          context,
                                          controller: controller,
                                          title: widget.content.title,
                                        );
                                      }
                                    },
                                    icon: const Icon(
                                      LucideIcons.maximize,
                                      color: AppColors.summerWood,
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
                const SizedBox(height: 4),
                Text(
                  'バックグラウンド再生に対応しています',
                  style: AppTypography.label(
                    size: 10,
                    color: AppColors.shuttleGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
