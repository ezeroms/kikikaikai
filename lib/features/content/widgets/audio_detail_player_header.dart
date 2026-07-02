import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/debug/playback_debug_log.dart';
import 'package:kikikaikai/core/media/content_playback_progress_resolver.dart';
import 'package:kikikaikai/core/media/format_media_duration.dart';
import 'package:kikikaikai/core/media/kikikaikai_media_handler.dart';
import 'package:kikikaikai/core/media/media_playback.dart';
import 'package:kikikaikai/core/media/playback_speed.dart';
import 'package:kikikaikai/features/content/widgets/playback_speed_sheet.dart';
import 'package:kikikaikai/features/content/widgets/sleep_timer_sheet.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_engagement.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/shared/widgets/circular_media_button.dart';
import 'package:kikikaikai/shared/widgets/figure_meta_row.dart';

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
  static const _seekBarTrackHeight = 3.5;

  bool _startingPlayback = false;

  bool get _isCurrent =>
      MediaPlayback.handler?.currentContent?.id == widget.content.id;

  bool get _isKikikaikai => widget.content.type == ContentType.kikikaikai;

  KikikaikaiMediaHandler? get _handler => MediaPlayback.handler;

  void _openPlaybackSpeedSheet() {
    final handler = _handler;
    if (handler == null) return;
    showPlaybackSpeedSheet(context, handler);
  }

  void _openSleepTimerSheet() {
    final handler = _handler;
    if (handler == null) return;
    showSleepTimerSheet(context, handler);
  }

  Widget _buildSpeedButton() {
    final handler = _handler;
    if (handler == null) {
      return _SideControlButton(
        label: '1x',
        onPressed: _openPlaybackSpeedSheet,
      );
    }

    return ValueListenableBuilder<double>(
      valueListenable: handler.playbackSpeedNotifier,
      builder: (context, speed, _) {
        return _SideControlButton(
          label: PlaybackSpeed.formatLabel(speed),
          onPressed: _openPlaybackSpeedSheet,
        );
      },
    );
  }

  Widget _buildSleepTimerButton() {
    final handler = _handler;
    if (handler == null) {
      return _SideControlButton(
        icon: LucideIcons.timer,
        onPressed: _openSleepTimerSheet,
      );
    }

    return ValueListenableBuilder(
      valueListenable: handler.sleepTimerNotifier,
      builder: (context, timer, _) {
        return _SideControlButton(
          icon: LucideIcons.timer,
          highlighted: timer != null,
          onPressed: _openSleepTimerSheet,
        );
      },
    );
  }

  Future<void> _startPlayback() async {
    if (_startingPlayback) return;

    final handler = _handler;
    PlaybackDebugLog.log(
      'AudioDetailHeader',
      'startPlayback content=${widget.content.id} '
      'handlerCurrent=${handler?.currentContent?.id} '
      'playing=${handler?.playingNotifier.value}',
    );

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
        final afterHandler = _handler;
        PlaybackDebugLog.log(
          'AudioDetailHeader',
          'startPlayback done content=${widget.content.id} '
          'handlerCurrent=${afterHandler?.currentContent?.id} '
          'playing=${afterHandler?.playingNotifier.value}',
        );
        setState(() => _startingPlayback = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isKikikaikai) {
      return _buildKikikaikaiHeader(context);
    }
    return _buildDefaultHeader(context);
  }

  Widget _buildKikikaikaiHeader(BuildContext context) {
    final handler = MediaPlayback.handler;
    final figuresAsync = ref.watch(contentFiguresProvider(widget.content.id));
    final engagement =
        ref.watch(contentEngagementProvider).valueOrNull ??
            ContentEngagementState.empty;
    final savedPlayback = engagement.playbackFor(widget.content.id);
    final figureNameStyle = AppTypography.titleSmall(size: 12).copyWith(
      fontWeight: FontWeight.w400,
    );

    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.content.title,
            style: AppTypography.title(
              size: 26,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          figuresAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (figures) => FigureMetaRow(
              figures: figures,
              dateLabel: '',
              showDate: false,
              compact: true,
              avatarRadius: 12,
              metaFontSize: 12,
              nameStyle: figureNameStyle,
            ),
          ),
          const SizedBox(height: 20),
          _buildKikikaikaiSeekBar(handler, savedPlayback),
          const SizedBox(height: 12),
          _buildKikikaikaiTransportRow(handler),
        ],
      ),
    );
  }

  Widget _buildKikikaikaiTransportRow(KikikaikaiMediaHandler? handler) {
    if (handler == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSpeedButton(),
          _SkipButton.back(onPressed: () {}),
          CircularMediaButton.control(
            playing: false,
            onPressed: _startingPlayback ? null : _startPlayback,
            size: 56,
          ),
          _SkipButton.forward(onPressed: () {}),
          _buildSleepTimerButton(),
        ],
      );
    }

    return ValueListenableBuilder<Content?>(
      valueListenable: handler.currentContentNotifier,
      builder: (context, current, _) {
        final isCurrent = current?.id == widget.content.id;

        if (!isCurrent) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSpeedButton(),
              _SkipButton.back(onPressed: () {}),
              CircularMediaButton.control(
                playing: false,
                onPressed: _startingPlayback ? null : _startPlayback,
                size: 56,
              ),
              _SkipButton.forward(onPressed: () {}),
              _buildSleepTimerButton(),
            ],
          );
        }

        return ValueListenableBuilder<bool>(
          valueListenable: handler.previewExpiredNotifier,
          builder: (context, previewExpired, _) {
            if (previewExpired) {
              return Text(
                'プレビューは30秒までです',
                style: AppTypography.label(color: AppColors.primary),
                textAlign: TextAlign.center,
              );
            }

            return ValueListenableBuilder<bool>(
              valueListenable: handler.playingNotifier,
              builder: (context, playing, _) {
                return StreamBuilder<PlaybackState>(
                  stream: handler.playbackState,
                  builder: (context, stateSnapshot) {
                    final position =
                        stateSnapshot.data?.updatePosition ?? Duration.zero;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSpeedButton(),
                        _SkipButton.back(
                          onPressed: () => handler.seek(
                            position - const Duration(seconds: 10),
                          ),
                        ),
                        CircularMediaButton.control(
                          playing: playing,
                          onPressed: () {
                            PlaybackDebugLog.log(
                              'AudioDetailHeader',
                              'toggle content=${widget.content.id} '
                              'playing=$playing',
                            );
                            if (playing) {
                              handler.pause();
                            } else {
                              handler.play();
                            }
                          },
                          size: 56,
                        ),
                        _SkipButton.forward(
                          onPressed: () => handler.seek(
                            position + const Duration(seconds: 10),
                          ),
                        ),
                        _buildSleepTimerButton(),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildKikikaikaiSeekBar(
    KikikaikaiMediaHandler? handler,
    ContentPlaybackProgress? savedPlayback,
  ) {
    if (handler != null && _isCurrent) {
      return _buildLiveSeekBar(handler);
    }

    final progress = ContentPlaybackProgressResolver.resolveDisplayProgress(
      handler: null,
      contentId: widget.content.id,
      savedProgress: savedPlayback,
      playbackState: null,
      content: widget.content,
    );
    final totalMs =
        progress.durationMs ?? widget.content.playbackDuration?.inMilliseconds;
    final position = Duration(milliseconds: progress.positionMs);
    final total = totalMs == null ? Duration.zero : Duration(milliseconds: totalMs);
    final ratio = progress.ratio.clamp(0.0, 1.0);

    return _SeekBarView(
      position: position,
      total: total,
      progress: ratio,
      trackHeight: _seekBarTrackHeight,
    );
  }

  Widget _buildLiveSeekBar(KikikaikaiMediaHandler handler) {
    return ValueListenableBuilder<bool>(
      valueListenable: handler.previewExpiredNotifier,
      builder: (context, previewExpired, _) {
        if (previewExpired) {
          return _buildKikikaikaiSeekBar(null, ref
              .read(contentEngagementProvider)
              .valueOrNull
              ?.playbackFor(widget.content.id));
        }

        return StreamBuilder<PlaybackState>(
          stream: handler.playbackState,
          builder: (context, stateSnapshot) {
            final position =
                stateSnapshot.data?.updatePosition ?? Duration.zero;

            return StreamBuilder<MediaItem?>(
              stream: handler.mediaItem,
              builder: (context, itemSnapshot) {
                final total = itemSnapshot.data?.duration ??
                    widget.content.playbackDuration ??
                    Duration.zero;
                final progress = total.inMilliseconds > 0
                    ? position.inMilliseconds / total.inMilliseconds
                    : 0.0;

                return _SeekBarView(
                  position: position,
                  total: total,
                  progress: progress.clamp(0.0, 1.0),
                  trackHeight: _seekBarTrackHeight,
                  onChanged: total.inMilliseconds > 0
                      ? (value) {
                          handler.seek(
                            Duration(
                              milliseconds:
                                  (total.inMilliseconds * value).round(),
                            ),
                          );
                        }
                      : null,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDefaultHeader(BuildContext context) {
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
          if (handler == null)
            Center(
              child: CircularMediaButton.control(
                playing: false,
                onPressed: _startingPlayback ? null : _startPlayback,
                size: 56,
              ),
            )
          else
            ValueListenableBuilder<Content?>(
              valueListenable: handler.currentContentNotifier,
              builder: (context, current, _) {
                if (current?.id != widget.content.id) {
                  return Center(
                    child: CircularMediaButton.control(
                      playing: false,
                      onPressed: _startingPlayback ? null : _startPlayback,
                      size: 56,
                    ),
                  );
                }
                return _buildActivePlaybackControls(handler);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActivePlaybackControls(KikikaikaiMediaHandler handler) {
    return ValueListenableBuilder<bool>(
      valueListenable: handler.previewExpiredNotifier,
      builder: (context, previewExpired, _) {
        if (previewExpired) {
          return Text(
            'プレビューは30秒までです',
            style: AppTypography.label(color: AppColors.primary),
            textAlign: TextAlign.center,
          );
        }

        return ValueListenableBuilder<bool>(
          valueListenable: handler.playingNotifier,
          builder: (context, playing, _) {
            return StreamBuilder<PlaybackState>(
              stream: handler.playbackState,
              builder: (context, stateSnapshot) {
                final position =
                    stateSnapshot.data?.updatePosition ?? Duration.zero;

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
                              disabledThumbRadius: 5,
                            ),
                            overlayShape: SliderComponentShape.noOverlay,
                            activeTrackColor: AppColors.onBase,
                            inactiveTrackColor:
                                AppColors.onBase.withValues(alpha: 0.2),
                            disabledActiveTrackColor: AppColors.onBase,
                            disabledInactiveTrackColor:
                                AppColors.onBase.withValues(alpha: 0.2),
                            thumbColor: AppColors.onBase,
                            disabledThumbColor: AppColors.onBase,
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
                            padding: EdgeInsets.zero,
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
                        if (!_isKikikaikai) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSpeedButton(),
                              _SkipButton.back(
                                onPressed: () => handler.seek(
                                  position - const Duration(seconds: 10),
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
                              _SkipButton.forward(
                                onPressed: () => handler.seek(
                                  position + const Duration(seconds: 10),
                                ),
                              ),
                              _buildSleepTimerButton(),
                            ],
                          ),
                        ],
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _SeekBarView extends StatelessWidget {
  const _SeekBarView({
    required this.position,
    required this.total,
    required this.progress,
    required this.trackHeight,
    this.onChanged,
  });

  final Duration position;
  final Duration total;
  final double progress;
  final double trackHeight;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: trackHeight,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 5,
              disabledThumbRadius: 5,
            ),
            overlayShape: SliderComponentShape.noOverlay,
            activeTrackColor: AppColors.onBase,
            inactiveTrackColor: AppColors.onBase.withValues(alpha: 0.2),
            disabledActiveTrackColor: AppColors.onBase,
            disabledInactiveTrackColor:
                AppColors.onBase.withValues(alpha: 0.2),
            thumbColor: AppColors.onBase,
            disabledThumbColor: AppColors.onBase,
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: onChanged,
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 6),
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
      ],
    );
  }
}

class _SideControlButton extends StatelessWidget {
  const _SideControlButton({
    this.label,
    this.icon,
    required this.onPressed,
    this.highlighted = false,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? const Color(0xFF00E676) : AppColors.onBase;

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
                  color: color,
                  weight: FontWeight.w600,
                ),
              )
            : Icon(icon, color: color, size: 22),
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton.back({required this.onPressed}) : forward = false;

  const _SkipButton.forward({required this.onPressed}) : forward = true;

  final bool forward;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          forward ? Icons.forward_10_rounded : Icons.replay_10_rounded,
          color: AppColors.onBase,
          size: 34,
        ),
      ),
    );
  }
}
