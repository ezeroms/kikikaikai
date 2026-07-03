import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kikikaikai/core/media/playback_speed.dart';
import 'package:kikikaikai/core/media/sleep_timer_state.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:video_player/video_player.dart';

enum MediaKind { audio, video }

class KikikaikaiMediaHandler extends BaseAudioHandler with SeekHandler {
  KikikaikaiMediaHandler() {
    _init();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  VideoPlayerController? _videoController;
  Timer? _previewTimer;
  Timer? _sleepTimer;
  Timer? _videoProgressTimer;
  MediaKind _kind = MediaKind.audio;
  Content? _currentContent;
  String? _loadedAudioUrl;
  int _playEpoch = 0;
  double _playbackSpeed = 1.0;
  SleepTimerMode? _sleepTimerMode;

  final videoControllerNotifier = ValueNotifier<VideoPlayerController?>(null);
  final previewExpiredNotifier = ValueNotifier<bool>(false);
  final sessionActiveNotifier = ValueNotifier<bool>(false);
  final fullscreenVideoNotifier = ValueNotifier<bool>(false);
  final currentContentNotifier = ValueNotifier<Content?>(null);
  final playbackSpeedNotifier = ValueNotifier<double>(1.0);
  final sleepTimerNotifier = ValueNotifier<SleepTimerState?>(null);
  final playingNotifier = ValueNotifier<bool>(false);

  Content? get currentContent => _currentContent;
  MediaKind get kind => _kind;

  void _setCurrentContent(Content? content) {
    _currentContent = content;
    currentContentNotifier.value = content;
  }

  /// タイムスタンプタップなど、停止中から再生を始める直前に UI を即反映する。
  void preparePlaybackAt(Duration position) {
    playingNotifier.value = true;
    playbackState.add(
      _buildPlaybackState(
        playing: true,
        processingState: _kind == MediaKind.video &&
                !(_videoController?.value.isInitialized ?? false)
            ? AudioProcessingState.loading
            : AudioProcessingState.ready,
        position: position,
        bufferedPosition: Duration.zero,
        duration: _kind == MediaKind.video
            ? (_videoController?.value.duration ??
                _currentContent?.playbackDuration)
            : (_audioPlayer.duration ?? _currentContent?.playbackDuration),
      ),
    );
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.none,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
    ));

    _audioPlayer.playerStateStream.listen((state) {
      if (_kind != MediaKind.audio) return;
      if (state.processingState == ProcessingState.completed &&
          _sleepTimerMode == SleepTimerMode.endOfEpisode) {
        clearSleepTimer();
      }
      _emitAudioPlaybackState(
        playing: state.playing,
        processingState: state.processingState,
      );
    });

    _audioPlayer.positionStream.listen((_) {
      if (_kind != MediaKind.audio) return;
      _emitAudioPlaybackState(
        playing: _audioPlayer.playing,
        processingState: _audioPlayer.processingState,
      );
    });

    _audioPlayer.durationStream.listen((_) {
      if (_currentContent != null && _kind == MediaKind.audio) {
        mediaItem.add(_toMediaItem(_currentContent!));
      }
    });
  }

  void _emitAudioPlaybackState({
    required bool playing,
    required ProcessingState processingState,
  }) {
    playingNotifier.value = playing;
    playbackState.add(_buildPlaybackState(
      playing: playing,
      processingState: _mapProcessingState(processingState),
      position: _audioPlayer.position,
      bufferedPosition: _audioPlayer.bufferedPosition,
      duration: _audioPlayer.duration,
    ));
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    return switch (state) {
      ProcessingState.idle => AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.completed,
    };
  }

  PlaybackState _buildPlaybackState({
    required bool playing,
    required AudioProcessingState processingState,
    required Duration position,
    required Duration bufferedPosition,
    required Duration? duration,
  }) {
    return PlaybackState(
      controls: [
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1],
      processingState: processingState,
      playing: playing,
      updatePosition: position,
      bufferedPosition: bufferedPosition,
      speed: _playbackSpeed,
      queueIndex: 0,
    );
  }

  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = PlaybackSpeed.snap(speed);
    playbackSpeedNotifier.value = _playbackSpeed;
    if (_kind == MediaKind.audio) {
      await _audioPlayer.setSpeed(_playbackSpeed);
      _emitAudioPlaybackState(
        playing: _audioPlayer.playing,
        processingState: _audioPlayer.processingState,
      );
    } else if (_kind == MediaKind.video) {
      await _videoController?.setPlaybackSpeed(_playbackSpeed);
    }
  }

  void setSleepTimerDuration(Duration duration) {
    clearSleepTimer();
    final expiresAt = DateTime.now().add(duration);
    _sleepTimerMode = SleepTimerMode.duration;
    sleepTimerNotifier.value = SleepTimerState(
      mode: SleepTimerMode.duration,
      expiresAt: expiresAt,
    );
    _sleepTimer = Timer(duration, _onSleepTimerElapsed);
  }

  void setSleepTimerEndOfEpisode() {
    clearSleepTimer();
    _sleepTimerMode = SleepTimerMode.endOfEpisode;
    sleepTimerNotifier.value = const SleepTimerState(
      mode: SleepTimerMode.endOfEpisode,
    );
  }

  void clearSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerMode = null;
    sleepTimerNotifier.value = null;
  }

  Future<void> _onSleepTimerElapsed() async {
    clearSleepTimer();
    if (_kind == MediaKind.audio && _audioPlayer.playing) {
      await pause();
    } else if (_kind == MediaKind.video &&
        (_videoController?.value.isPlaying ?? false)) {
      await pause();
    }
  }

  Future<void> _applyPlaybackSpeed() async {
    if (_kind == MediaKind.audio) {
      await _audioPlayer.setSpeed(_playbackSpeed);
    } else if (_kind == MediaKind.video) {
      await _videoController?.setPlaybackSpeed(_playbackSpeed);
    }
  }

  Future<void> playContent(
    Content content, {
    Duration? previewLimit,
    Duration? startPosition,
  }) async {
    if (content.mediaUrl == null) return;

    final epoch = ++_playEpoch;
    previewExpiredNotifier.value = false;
    _previewTimer?.cancel();

    if (_currentContent?.id != content.id &&
        _sleepTimerMode == SleepTimerMode.endOfEpisode) {
      clearSleepTimer();
    }

    debugPrint(
      'playContent: id=${content.id} type=${content.type} '
      'epoch=$epoch current=${_currentContent?.id} loaded=$_loadedAudioUrl',
    );

    try {
      if (content.usesVideoDetailLayout) {
        _setCurrentContent(content);
        _kind = MediaKind.video;
        sessionActiveNotifier.value = true;
        preparePlaybackAt(startPosition ?? Duration.zero);
        mediaItem.add(_toMediaItem(content));
        await _playVideo(content.mediaUrl!, epoch, startPosition: startPosition);
        if (epoch != _playEpoch) return;
      } else if (content.type.isAudioPlayback) {
        _setCurrentContent(content);
        _kind = MediaKind.audio;
        sessionActiveNotifier.value = true;
        preparePlaybackAt(startPosition ?? Duration.zero);
        mediaItem.add(_toMediaItem(content));
        await _playAudio(
          content.mediaUrl!,
          epoch,
          startPosition: startPosition,
        );
        if (epoch != _playEpoch) return;
      } else {
        return;
      }

      if (previewLimit != null) {
        _previewTimer = Timer(previewLimit, () async {
          await pause();
          previewExpiredNotifier.value = true;
        });
      }
    } catch (e, stackTrace) {
      if (epoch != _playEpoch) return;
      debugPrint('playContent failed for ${content.id}: $e\n$stackTrace');
      await _resetPlaybackSession();
      rethrow;
    }
  }

  Future<void> _resetPlaybackSession() async {
    _playEpoch++;
    _previewTimer?.cancel();
    _loadedAudioUrl = null;
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    await _disposeVideo();
    _setCurrentContent(null);
    sessionActiveNotifier.value = false;
    previewExpiredNotifier.value = false;
    playingNotifier.value = false;
  }

  MediaItem _toMediaItem(Content content) {
    return MediaItem(
      id: content.id,
      title: content.title,
      artist: '品品団地',
      album: content.type.label,
      duration: _kind == MediaKind.audio
          ? _audioPlayer.duration
          : _videoController?.value.duration,
    );
  }

  Future<void> _playAudio(
    String source,
    int epoch, {
    Duration? startPosition,
  }) async {
    _kind = MediaKind.audio;
    await _disposeVideo();
    if (epoch != _playEpoch) return;

    final session = await AudioSession.instance;
    await session.setActive(true);

    // 一時停止中の同じ音源なら再読み込みせず再開する
    if (_loadedAudioUrl == source &&
        _audioPlayer.processingState == ProcessingState.ready) {
      debugPrint('audio: resume loaded source $source');
      if (startPosition != null && startPosition > Duration.zero) {
        await _audioPlayer.seek(startPosition);
      }
      await _applyPlaybackSpeed();
      await _audioPlayer.play();
      return;
    }

    debugPrint(
      'audio: load source=$source loaded=$_loadedAudioUrl '
      'state=${_audioPlayer.processingState}',
    );

    try {
      await _audioPlayer.stop();
    } catch (_) {}
    if (epoch != _playEpoch) return;

    await _audioPlayer.setAudioSource(_resolveAudioSource(source));
    _loadedAudioUrl = source;
    if (epoch != _playEpoch) return;

    await _applyPlaybackSpeed();

    if (_currentContent != null) {
      mediaItem.add(_toMediaItem(_currentContent!));
    }
    if (startPosition != null && startPosition > Duration.zero) {
      await _audioPlayer.seek(startPosition);
    }
    await _audioPlayer.play();
  }

  Future<void> _playVideo(
    String source,
    int epoch, {
    Duration? startPosition,
  }) async {
    if (epoch != _playEpoch) return;
    _kind = MediaKind.video;
    await _audioPlayer.stop();
    await _disposeVideo();

    final controller = source.startsWith('assets/')
        ? VideoPlayerController.asset(source)
        : VideoPlayerController.networkUrl(Uri.parse(source));

    await controller.initialize();
    if (epoch != _playEpoch) {
      await controller.dispose();
      return;
    }
    controller.setLooping(false);
    await controller.setPlaybackSpeed(_playbackSpeed);
    _videoController = controller;
    videoControllerNotifier.value = controller;
    controller.addListener(_onVideoTick);

    if (_currentContent != null) {
      mediaItem.add(_toMediaItem(_currentContent!));
    }

    if (startPosition != null && startPosition > Duration.zero) {
      await controller.seekTo(startPosition);
    }

    await controller.play();
    _startVideoProgressTimer();
    _onVideoTick();
  }

  void _startVideoProgressTimer() {
    _videoProgressTimer?.cancel();
    _videoProgressTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _onVideoTick(),
    );
  }

  void _stopVideoProgressTimer() {
    _videoProgressTimer?.cancel();
    _videoProgressTimer = null;
  }

  void _onVideoTick() {
    final controller = _videoController;
    if (controller == null || _kind != MediaKind.video) return;
    final value = controller.value;
    playingNotifier.value = value.isPlaying;
    playbackState.add(_buildPlaybackState(
      playing: value.isPlaying,
      processingState: value.isInitialized
          ? AudioProcessingState.ready
          : AudioProcessingState.loading,
      position: value.position,
      bufferedPosition:
          value.buffered.isEmpty ? Duration.zero : value.buffered.last.end,
      duration: value.duration,
    ));
  }

  AudioSource _resolveAudioSource(String source) {
    if (source.startsWith('assets/')) {
      return AudioSource.asset(source);
    }
    return AudioSource.uri(Uri.parse(source));
  }

  Future<void> _disposeVideo() async {
    _stopVideoProgressTimer();
    _videoController?.removeListener(_onVideoTick);
    await _videoController?.dispose();
    _videoController = null;
    videoControllerNotifier.value = null;
  }

  @override
  Future<void> play() async {
    if (_kind == MediaKind.video) {
      await _videoController?.play();
    } else {
      await _audioPlayer.play();
    }
  }

  @override
  Future<void> pause() async {
    if (_kind == MediaKind.video) {
      await _videoController?.pause();
    } else {
      await _audioPlayer.pause();
    }
  }

  @override
  Future<void> stop() async {
    _playEpoch++;
    _previewTimer?.cancel();
    clearSleepTimer();
    _loadedAudioUrl = null;
    if (_kind == MediaKind.video) {
      await _disposeVideo();
    } else {
      await _audioPlayer.stop();
    }
    previewExpiredNotifier.value = false;
    _setCurrentContent(null);
    sessionActiveNotifier.value = false;
    playingNotifier.value = false;
  }

  @override
  Future<void> seek(Duration position) async {
    if (_kind == MediaKind.video) {
      await _videoController?.seekTo(position);
    } else {
      await _audioPlayer.seek(position);
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await super.onTaskRemoved();
  }

  Future<void> disposeHandler() async {
    _previewTimer?.cancel();
    clearSleepTimer();
    await _audioPlayer.dispose();
    await _disposeVideo();
  }
}
