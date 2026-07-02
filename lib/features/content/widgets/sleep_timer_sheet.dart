import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/media/kikikaikai_media_handler.dart';
import 'package:kikikaikai/core/media/sleep_timer_state.dart';
import 'package:kikikaikai/features/content/widgets/player_bottom_sheet.dart';

Future<void> showSleepTimerSheet(
  BuildContext context,
  KikikaikaiMediaHandler handler,
) {
  return showPlayerBottomSheet<void>(
    context,
    title: 'スリープタイマー',
    child: _SleepTimerSheetBody(handler: handler),
  );
}

class _SleepTimerSheetBody extends StatelessWidget {
  const _SleepTimerSheetBody({required this.handler});

  final KikikaikaiMediaHandler handler;

  static const _options = <(Duration?, String)>[
    (Duration(minutes: 5), '5分'),
    (Duration(minutes: 10), '10分'),
    (Duration(minutes: 15), '15分'),
    (Duration(minutes: 30), '30分'),
    (Duration(minutes: 45), '45分'),
    (Duration(hours: 1), '1時間'),
    (null, 'エピソード終了時'),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SleepTimerState?>(
      valueListenable: handler.sleepTimerNotifier,
      builder: (context, activeTimer, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (activeTimer != null) ...[
              ListTile(
                title: Text(
                  _activeTimerLabel(activeTimer),
                  style: AppTypography.body(
                    size: 15,
                    color: AppColors.muted,
                  ),
                ),
                trailing: TextButton(
                  onPressed: () {
                    handler.clearSleepTimer();
                    Navigator.of(context).pop();
                  },
                  child: const Text('解除'),
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
            ],
            for (final option in _options)
              ListTile(
                title: Text(
                  option.$2,
                  style: AppTypography.body(size: 17),
                ),
                onTap: () {
                  if (option.$1 == null) {
                    handler.setSleepTimerEndOfEpisode();
                  } else {
                    handler.setSleepTimerDuration(option.$1!);
                  }
                  Navigator.of(context).pop();
                },
              ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  String _activeTimerLabel(SleepTimerState timer) {
    return switch (timer.mode) {
      SleepTimerMode.endOfEpisode => 'エピソード終了時に停止',
      SleepTimerMode.duration => () {
          final remaining = timer.remaining;
          if (remaining == null) return 'タイマー設定中';
          final minutes = remaining.inMinutes;
          final seconds = remaining.inSeconds % 60;
          return 'あと $minutes分${seconds.toString().padLeft(2, '0')}秒';
        }(),
    };
  }
}
