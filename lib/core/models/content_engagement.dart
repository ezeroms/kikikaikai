class ContentPlaybackProgress {
  const ContentPlaybackProgress({
    required this.positionMs,
    this.durationMs,
    this.completed = false,
  });

  final int positionMs;
  final int? durationMs;
  final bool completed;

  double get ratio {
    if (completed) return 1;
    final total = durationMs;
    if (total == null || total <= 0) return 0;
    return (positionMs / total).clamp(0.0, 1.0);
  }

  bool get hasProgress => completed || positionMs > 0;

  ContentPlaybackProgress copyWith({
    int? positionMs,
    int? durationMs,
    bool? completed,
  }) {
    return ContentPlaybackProgress(
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() => {
        'positionMs': positionMs,
        if (durationMs != null) 'durationMs': durationMs,
        'completed': completed,
      };

  factory ContentPlaybackProgress.fromJson(Map<String, dynamic> json) {
    return ContentPlaybackProgress(
      positionMs: json['positionMs'] as int? ?? 0,
      durationMs: json['durationMs'] as int?,
      completed: json['completed'] as bool? ?? false,
    );
  }
}

class ContentEngagementState {
  const ContentEngagementState({
    this.viewedIds = const {},
    this.playback = const {},
  });

  static const empty = ContentEngagementState();

  final Set<String> viewedIds;
  final Map<String, ContentPlaybackProgress> playback;

  bool isViewed(String contentId) => viewedIds.contains(contentId);

  ContentPlaybackProgress? playbackFor(String contentId) => playback[contentId];

  ContentEngagementState copyWith({
    Set<String>? viewedIds,
    Map<String, ContentPlaybackProgress>? playback,
  }) {
    return ContentEngagementState(
      viewedIds: viewedIds ?? this.viewedIds,
      playback: playback ?? this.playback,
    );
  }
}
