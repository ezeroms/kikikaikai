enum SleepTimerMode {
  duration,
  endOfEpisode,
}

class SleepTimerState {
  const SleepTimerState({
    required this.mode,
    this.expiresAt,
  });

  final SleepTimerMode mode;
  final DateTime? expiresAt;

  Duration? get remaining {
    if (expiresAt == null) return null;
    final diff = expiresAt!.difference(DateTime.now());
    if (diff.isNegative) return Duration.zero;
    return diff;
  }
}
