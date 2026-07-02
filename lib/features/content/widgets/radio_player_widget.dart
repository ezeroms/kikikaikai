import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/media/content_playback_progress_resolver.dart';
import 'package:kikikaikai/core/media/format_media_duration.dart';
import 'package:kikikaikai/core/media/media_playback.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/shared/widgets/circular_media_button.dart';

class RadioPlayerWidget extends ConsumerStatefulWidget {
  const RadioPlayerWidget({
    super.key,
    required this.content,
    this.previewLimit,
  });

  final Content content;
  final Duration? previewLimit;

  @override
  ConsumerState<RadioPlayerWidget> createState() => _RadioPlayerWidgetState();
}

class _RadioPlayerWidgetState extends ConsumerState<RadioPlayerWidget> {
  bool _isCurrentContent() {
    return MediaPlayback.handler?.currentContent?.id == widget.content.id;
  }

  Future<void> _startPlayback() async {
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
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final handler = MediaPlayback.handler;
    final isActive = _isCurrentContent();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  widget.content.displayThumbnail,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.content.type.label,
                      style: AppTypography.overline(),
                    ),
                    Text(
                      widget.content.title,
                      style: AppTypography.titleSmall(size: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!isActive)
            Center(
              child: CircularMediaButton.overlay(
                onPressed: _startPlayback,
                size: 64,
              ),
            )
          else if (handler != null)
            ValueListenableBuilder<bool>(
              valueListenable: handler.previewExpiredNotifier,
              builder: (context, previewExpired, _) {
                if (previewExpired) {
                  return Text(
                    'プレビューは30秒までです',
                    style: AppTypography.label(color: AppColors.primary),
                  );
                }
                return StreamBuilder<PlaybackState>(
                  stream: handler.playbackState,
                  builder: (context, stateSnapshot) {
                    final state = stateSnapshot.data;
                    final playing = state?.playing ?? false;
                    final position = state?.updatePosition ?? Duration.zero;
                    return StreamBuilder<MediaItem?>(
                      stream: handler.mediaItem,
                      builder: (context, itemSnapshot) {
                        final total =
                            itemSnapshot.data?.duration ?? Duration.zero;
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
                                          milliseconds:
                                              (total.inMilliseconds * v)
                                                  .round(),
                                        ),
                                      );
                                    }
                                  : null,
                              activeColor: AppColors.primary,
                              inactiveColor: AppColors.muted,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    position - const Duration(seconds: 15),
                                  ),
                                  icon: const Icon(
                                    LucideIcons.rotate_ccw,
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
                                    position + const Duration(seconds: 15),
                                  ),
                                  icon: const Icon(
                                    LucideIcons.rotate_cw,
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
                );
              },
            ),
          if (isActive) ...[
            const SizedBox(height: 4),
            Text(
              'バックグラウンド再生に対応しています',
              style: AppTypography.label(
                size: 10,
                color: AppColors.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
