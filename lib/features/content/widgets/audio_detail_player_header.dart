import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/debug/playback_debug_log.dart';
import 'package:kikikaikai/core/format/format_content_date.dart';
import 'package:kikikaikai/core/media/content_playback_progress_resolver.dart';
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
import 'package:kikikaikai/shared/widgets/media_player_controls.dart';

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
      return MediaPlayerSideControlButton(
        label: '1x',
        onPressed: _openPlaybackSpeedSheet,
      );
    }

    return ValueListenableBuilder<double>(
      valueListenable: handler.playbackSpeedNotifier,
      builder: (context, speed, _) {
        return MediaPlayerSideControlButton(
          label: PlaybackSpeed.formatLabel(speed),
          onPressed: _openPlaybackSpeedSheet,
        );
      },
    );
  }

  Widget _buildSleepTimerButton() {
    final handler = _handler;
    if (handler == null) {
      return MediaPlayerSideControlButton(
        icon: LucideIcons.timer,
        onPressed: _openSleepTimerSheet,
      );
    }

    return ValueListenableBuilder(
      valueListenable: handler.sleepTimerNotifier,
      builder: (context, timer, _) {
        return MediaPlayerSideControlButton(
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
    return _buildPlayerHeader(context);
  }

  Widget _buildPlayerHeader(BuildContext context) {
    final handler = MediaPlayback.handler;
    final figuresAsync = ref.watch(contentFiguresProvider(widget.content.id));
    final engagement =
        ref.watch(contentEngagementProvider).valueOrNull ??
            ContentEngagementState.empty;
    final savedPlayback = engagement.playbackFor(widget.content.id);
    final dateLabel = formatContentDate(widget.content.publishedAt);
    final figureNameStyle = AppTypography.titleSmall(size: 14).copyWith(
      fontWeight: FontWeight.w400,
    );
    final isRadio = widget.content.type == ContentType.audio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isRadio)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              widget.content.displayThumbnail,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, isRadio ? 32 : 8, 20, 16),
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
                  dateLabel: dateLabel,
                  showDate: true,
                  compact: true,
                  avatarRadius: 14,
                  metaFontSize: 14,
                  nameStyle: figureNameStyle,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (handler == null)
                _buildSeekBar(null, savedPlayback)
              else
                ValueListenableBuilder<Content?>(
                  valueListenable: handler.currentContentNotifier,
                  builder: (context, current, _) {
                    final isCurrent = current?.id == widget.content.id;
                    return _buildSeekBar(
                      isCurrent ? handler : null,
                      savedPlayback,
                    );
                  },
                ),
              const SizedBox(height: 12),
              _buildTransportRow(handler),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransportRow(KikikaikaiMediaHandler? handler) {
    if (handler == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSpeedButton(),
          MediaPlayerSkipButton.back(onPressed: () {}),
          CircularMediaButton.control(
            playing: false,
            onPressed: _startingPlayback ? null : _startPlayback,
            size: 56,
          ),
          MediaPlayerSkipButton.forward(onPressed: () {}),
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
              MediaPlayerSkipButton.back(onPressed: () {}),
              CircularMediaButton.control(
                playing: false,
                onPressed: _startingPlayback ? null : _startPlayback,
                size: 56,
              ),
              MediaPlayerSkipButton.forward(onPressed: () {}),
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
                        MediaPlayerSkipButton.back(
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
                        MediaPlayerSkipButton.forward(
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

  Widget _buildSeekBar(
    KikikaikaiMediaHandler? handler,
    ContentPlaybackProgress? savedPlayback,
  ) {
    if (handler != null) {
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

    return MediaPlayerSeekBar(
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
          return _buildSeekBar(null, ref
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

                return MediaPlayerSeekBar(
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
}
