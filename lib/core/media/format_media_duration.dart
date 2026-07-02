/// メディア向けの時間表示（分まで。秒は表示しない）
String formatMediaDuration(Duration duration) {
  if (duration.inSeconds <= 0) return '0分';

  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);

  if (hours >= 1) {
    if (minutes == 0) return '$hours時間';
    return '$hours時間$minutes分';
  }

  if (duration.inMinutes >= 1) return '${duration.inMinutes}分';
  return '1分';
}

/// 残り時間表示（切り上げて分単位にする）
String formatMediaDurationRemaining(Duration remaining) {
  if (remaining.inSeconds <= 0) return '残り0分';

  final totalMinutes = (remaining.inSeconds + 59) ~/ 60;
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;

  if (hours >= 1) {
    if (minutes == 0) return '残り$hours時間';
    return '残り$hours時間$minutes分';
  }

  return '残り$totalMinutes分';
}

/// プレーヤー用の時刻表示（例: 55:20 / 1:40:37）
String formatPlayerClock(Duration duration) {
  if (duration.inSeconds <= 0) return '0:00';

  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}
