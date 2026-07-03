import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/core/media/media_playback.dart';
import 'package:kikikaikai/core/providers/providers.dart';

/// 音声・動画の再生進捗を SharedPreferences へ同期する
class PlaybackEngagementListener extends ConsumerStatefulWidget {
  const PlaybackEngagementListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PlaybackEngagementListener> createState() =>
      _PlaybackEngagementListenerState();
}

class _PlaybackEngagementListenerState
    extends ConsumerState<PlaybackEngagementListener> {
  StreamSubscription<PlaybackState>? _subscription;
  VoidCallback? _contentListener;
  Timer? _saveTimer;
  String? _pendingContentId;
  String? _trackedContentId;
  int _pendingPositionMs = 0;
  int? _pendingDurationMs;
  bool _pendingCompleted = false;

  @override
  void initState() {
    super.initState();
    _attach();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    final contentListener = _contentListener;
    if (contentListener != null) {
      MediaPlayback.handler?.currentContentNotifier
          .removeListener(contentListener);
    }
    _saveTimer?.cancel();
    _flushPending(force: true);
    super.dispose();
  }

  void _attach() {
    final handler = MediaPlayback.handler;
    if (handler == null) return;

    _subscription = handler.playbackState.listen(_onPlaybackState);
    _contentListener = _onCurrentContentChanged;
    handler.currentContentNotifier.addListener(_contentListener!);
    _trackedContentId = handler.currentContent?.id;
  }

  void _onCurrentContentChanged() {
    final contentId = MediaPlayback.handler?.currentContent?.id;
    if (_trackedContentId != null && _trackedContentId != contentId) {
      _flushPending(force: true);
    }
    _trackedContentId = contentId;
  }

  void _onPlaybackState(PlaybackState state) {
    final handler = MediaPlayback.handler;
    final content = handler?.currentContent;
    if (content == null || !content.type.tracksPlaybackProgress) return;

    final duration = handler?.mediaItem.value?.duration ?? Duration.zero;
    final position = state.updatePosition;
    final completed = state.processingState == AudioProcessingState.completed ||
        (duration.inMilliseconds > 0 &&
            position.inMilliseconds >= (duration.inMilliseconds * 0.95).round());

    _pendingContentId = content.id;
    _pendingPositionMs = position.inMilliseconds;
    _pendingDurationMs =
        duration.inMilliseconds > 0 ? duration.inMilliseconds : null;
    _pendingCompleted = completed;

    if (completed) {
      _flushPending(force: true);
      return;
    }

    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), () => _flushPending());
  }

  Future<void> _flushPending({bool force = false}) async {
    _saveTimer?.cancel();
    _saveTimer = null;

    final contentId = _pendingContentId;
    if (contentId == null) return;

    await ref.read(contentEngagementProvider.notifier).updatePlaybackProgress(
          contentId: contentId,
          positionMs: _pendingPositionMs,
          durationMs: _pendingDurationMs,
          completed: _pendingCompleted,
        );

    if (force) {
      _pendingContentId = null;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
