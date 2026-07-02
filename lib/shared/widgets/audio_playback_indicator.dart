import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/media/format_media_duration.dart';
import 'package:kikikaikai/core/models/content_engagement.dart';

/// Spotify 風 — 日付・再生時間・進捗バー
class AudioPlaybackIndicator extends StatelessWidget {
  const AudioPlaybackIndicator({
    super.key,
    required this.dateLabel,
    required this.progress,
    this.totalDurationMs,
    this.isPlaying = false,
  });

  static const _progressActive = Color(0xFF1ED760);
  static const _progressTrack = Color(0xFF3E3E3E);

  final String dateLabel;
  final ContentPlaybackProgress progress;

  /// 未再生時に使う総尺（progress.durationMs が無い場合）
  final int? totalDurationMs;

  /// このコンテンツが現在再生中か
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final completed = progress.completed;
    final resolvedTotalMs = progress.durationMs ?? totalDurationMs;
    final ratio = progress.ratio.clamp(0.0, 1.0);

    final showRemaining = !completed &&
        resolvedTotalMs != null &&
        resolvedTotalMs > 0 &&
        (isPlaying || progress.positionMs > 0);

    final String statusText;
    if (showRemaining) {
      final left = resolvedTotalMs - progress.positionMs;
      final remaining =
          Duration(milliseconds: left.clamp(0, resolvedTotalMs));
      statusText = _joinDateAndDuration(
        dateLabel,
        formatMediaDurationRemaining(remaining),
      );
    } else if (resolvedTotalMs != null && resolvedTotalMs > 0) {
      statusText = _joinDateAndDuration(
        dateLabel,
        formatMediaDuration(Duration(milliseconds: resolvedTotalMs)),
      );
    } else {
      statusText = dateLabel;
    }

    return Row(
      children: [
        Flexible(
          child: Text(
            statusText,
            style: AppTypography.body(
              size: 12,
              color: AppColors.muted,
              weight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 72,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: completed ? 1 : (ratio > 0 ? ratio : 0),
              backgroundColor: _progressTrack,
              color: _progressActive,
            ),
          ),
        ),
        if (completed) ...[
          const SizedBox(width: 6),
          Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: _progressActive,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 11,
              color: Colors.black,
            ),
          ),
        ],
      ],
    );
  }

  static String _joinDateAndDuration(String date, String duration) {
    if (date.isEmpty) return duration;
    if (duration.isEmpty) return date;
    return '$date ・ $duration';
  }
}
