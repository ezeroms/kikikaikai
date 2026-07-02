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

/// 奇奇怪怪・ラジオ詳細の上半分プレーヤー
class AudioDetailPlayerHeader extends ConsumerStatefulWidget {
  const AudioDetailPlayerHeader({
    super.key,
    required this.content,
    this.previewLimit,
  });

  final Content content;
  final Duration? previewLimit;

  @override
  ConsumerState<AudioDetailPlayerHeader> createState() =>
      _AudioDetailPlayerHeaderState();
}

class _AudioDetailPlayerHeaderState extends ConsumerState<AudioDetailPlayerHeader> {
  bool get _isCurrent =>
      MediaPlayback.handler?.currentContent?.id == widget.content.id;

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

    return Container(
      width: double.infinity,
      color: AppColors.base,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  widget.content.displayThumbnail,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.content.title,
                      style: AppTypography.titleSmall(size: 16),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.content.type.label,
                      style: AppTypography.body(
                        size: 13,
                        color: AppColors.muted,
                        weight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  LucideIcons.plus,
                  color: AppColors.onBase,
                  size: 22,
                ),
                tooltip: 'プレイリストに追加',
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!_isCurrent || handler == null)
            Center(
              child: CircularMediaButton.control(
                playing: false,
                onPressed: _startPlayback,
                size: 56,
              ),
            )
          else
            ValueListenableBuilder<bool>(
              valueListenable: handler.previewExpiredNotifier,
              builder: (context, previewExpired, _) {
                if (previewExpired) {
                  return Text(
                    'プレビューは30秒までです',
                    style: AppTypography.label(color: AppColors.primary),
                    textAlign: TextAlign.center,
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
                        final total = itemSnapshot.data?.duration ??
                            widget.content.playbackDuration ??
                            Duration.zero;
                        final progress = total.inMilliseconds > 0
                            ? position.inMilliseconds / total.inMilliseconds
                            : 0.0;

                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 5,
                                ),
                                overlayShape: SliderComponentShape.noOverlay,
                                activeTrackColor: AppColors.onBase,
                                inactiveTrackColor:
                                    AppColors.onBase.withValues(alpha: 0.2),
                                thumbColor: AppColors.onBase,
                              ),
                              child: Slider(
                                value: progress.clamp(0.0, 1.0),
                                onChanged: total.inMilliseconds > 0
                                    ? (value) {
                                        handler.seek(
                                          Duration(
                                            milliseconds:
                                                (total.inMilliseconds * value)
                                                    .round(),
                                          ),
                                        );
                                      }
                                    : null,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatPlayerClock(position),
                                  style: AppTypography.caption(size: 12),
                                ),
                                Text(
                                  formatPlayerClock(total),
                                  style: AppTypography.caption(size: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _SideControlButton(
                                  label: '1x',
                                  onPressed: () {},
                                ),
                                _SkipButton(
                                  icon: LucideIcons.rotate_ccw,
                                  onPressed: () => handler.seek(
                                    position - const Duration(seconds: 15),
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
                                  size: 56,
                                ),
                                _SkipButton(
                                  icon: LucideIcons.rotate_cw,
                                  onPressed: () => handler.seek(
                                    position + const Duration(seconds: 15),
                                  ),
                                ),
                                _SideControlButton(
                                  icon: LucideIcons.timer,
                                  onPressed: () {},
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
        ],
      ),
    );
  }
}

class _SideControlButton extends StatelessWidget {
  const _SideControlButton({
    this.label,
    this.icon,
    required this.onPressed,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: IconButton(
        onPressed: onPressed,
        icon: label != null
            ? Text(
                label!,
                style: AppTypography.body(
                  size: 14,
                  color: AppColors.onBase,
                  weight: FontWeight.w600,
                ),
              )
            : Icon(icon, color: AppColors.onBase, size: 22),
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: AppColors.onBase, size: 28),
          ),
          Positioned(
            bottom: 8,
            child: Text(
              '15',
              style: AppTypography.label(
                size: 9,
                color: AppColors.onBase,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
