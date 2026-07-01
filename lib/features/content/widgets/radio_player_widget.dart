import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/media/media_playback.dart';
import 'package:kikikaikai/core/models/content.dart';

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
    await MediaPlayback.playContent(
      widget.content,
      previewLimit: widget.previewLimit,
    );
    if (mounted) setState(() {});
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final handler = MediaPlayback.handler;
    final isActive = _isCurrentContent();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
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
              child: FilledButton.icon(
                onPressed: _startPlayback,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.mangoTango,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                ),
                icon: const Icon(LucideIcons.play, size: 20),
                label: const Text('再生する'),
              ),
            )
          else if (handler != null)
            ValueListenableBuilder<bool>(
              valueListenable: handler.previewExpiredNotifier,
              builder: (context, previewExpired, _) {
                if (previewExpired) {
                  return Text(
                    'プレビューは30秒までです',
                    style: AppTypography.label(color: AppColors.mangoTango),
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
                              activeColor: AppColors.mangoTango,
                              inactiveColor: AppColors.shuttleGray,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: AppTypography.caption(size: 11),
                                ),
                                Text(
                                  _formatDuration(total),
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
                color: AppColors.shuttleGray,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
