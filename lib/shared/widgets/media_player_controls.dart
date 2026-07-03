import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/media/format_media_duration.dart';
import 'package:kikikaikai/core/media/kikikaikai_media_handler.dart';
import 'package:kikikaikai/core/media/playback_speed.dart';
import 'package:kikikaikai/features/content/widgets/playback_speed_sheet.dart';
import 'package:kikikaikai/features/content/widgets/sleep_timer_sheet.dart';
import 'package:kikikaikai/shared/widgets/circular_media_button.dart';

class MediaPlayerSeekBar extends StatelessWidget {
  const MediaPlayerSeekBar({
    super.key,
    required this.position,
    required this.total,
    required this.progress,
    this.trackHeight = 3.5,
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
            disabledInactiveTrackColor: AppColors.onBase.withValues(alpha: 0.2),
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

class MediaPlayerSideControlButton extends StatelessWidget {
  const MediaPlayerSideControlButton({
    super.key,
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

class MediaPlayerSkipButton extends StatelessWidget {
  const MediaPlayerSkipButton.back({super.key, required this.onPressed})
      : forward = false;

  const MediaPlayerSkipButton.forward({super.key, required this.onPressed})
      : forward = true;

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

class MediaPlayerTransportRow extends StatelessWidget {
  const MediaPlayerTransportRow({
    super.key,
    required this.handler,
    required this.playing,
    required this.position,
    required this.onPlayPause,
    this.previewExpiredMessage,
  });

  final KikikaikaiMediaHandler handler;
  final bool playing;
  final Duration position;
  final VoidCallback onPlayPause;
  final String? previewExpiredMessage;

  void _openPlaybackSpeedSheet(BuildContext context) {
    showPlaybackSpeedSheet(context, handler);
  }

  void _openSleepTimerSheet(BuildContext context) {
    showSleepTimerSheet(context, handler);
  }

  @override
  Widget build(BuildContext context) {
    if (previewExpiredMessage != null) {
      return Text(
        previewExpiredMessage!,
        style: AppTypography.label(color: AppColors.primary),
        textAlign: TextAlign.center,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ValueListenableBuilder<double>(
          valueListenable: handler.playbackSpeedNotifier,
          builder: (context, speed, _) {
            return MediaPlayerSideControlButton(
              label: PlaybackSpeed.formatLabel(speed),
              onPressed: () => _openPlaybackSpeedSheet(context),
            );
          },
        ),
        MediaPlayerSkipButton.back(
          onPressed: () => handler.seek(
            position - const Duration(seconds: 10),
          ),
        ),
        CircularMediaButton.control(
          playing: playing,
          onPressed: onPlayPause,
          size: 56,
        ),
        MediaPlayerSkipButton.forward(
          onPressed: () => handler.seek(
            position + const Duration(seconds: 10),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: handler.sleepTimerNotifier,
          builder: (context, timer, _) {
            return MediaPlayerSideControlButton(
              icon: LucideIcons.timer,
              highlighted: timer != null,
              onPressed: () => _openSleepTimerSheet(context),
            );
          },
        ),
      ],
    );
  }
}
