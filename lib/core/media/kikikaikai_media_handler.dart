import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:video_player/video_player.dart';

enum MediaKind { audio, video }

class KikikaikaiMediaHandler extends BaseAudioHandler with SeekHandler {
  KikikaikaiMediaHandler() {
    _init();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  VideoPlayerController? _videoController;
  Timer? _previewTimer;
  Timer? _videoProgressTimer;
  MediaKind _kind = MediaKind.audio;
  Content? _currentContent;

  final videoControllerNotifier = ValueNotifier<VideoPlayerController?>(null);
  final previewExpiredNotifier = ValueNotifier<bool>(false);
  final sessionActiveNotifier = ValueNotifier<bool>(false);

  Content? get currentContent => _currentContent;
  MediaKind get kind => _kind;

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
      speed: 1.0,
      queueIndex: 0,
    );
  }

  Future<void> playContent(
    Content content, {
    Duration? previewLimit,
  }) async {
    if (content.mediaUrl == null) return;

    previewExpiredNotifier.value = false;
    _previewTimer?.cancel();
    _currentContent = content;
    sessionActiveNotifier.value = true;
    mediaItem.add(_toMediaItem(content));

    if (content.type == ContentType.video) {
      await _playVideo(content.mediaUrl!);
    } else if (content.type == ContentType.audio) {
      await _playAudio(content.mediaUrl!);
    }

    if (previewLimit != null) {
      _previewTimer = Timer(previewLimit, () async {
        await pause();
        previewExpiredNotifier.value = true;
      });
    }
  }

  MediaItem _toMediaItem(Content content) {
    return MediaItem(
      id: content.id,
      title: content.title,
      artist: '奇奇怪怪',
      album: content.type.label,
      duration: _kind == MediaKind.audio
          ? _audioPlayer.duration
          : _videoController?.value.duration,
    );
  }

  Future<void> _playAudio(String source) async {
    _kind = MediaKind.audio;
    await _disposeVideo();
    await _audioPlayer.setAudioSource(_resolveAudioSource(source));
    if (_currentContent != null) {
      mediaItem.add(_toMediaItem(_currentContent!));
    }
    await _audioPlayer.play();
  }

  Future<void> _playVideo(String source) async {
    _kind = MediaKind.video;
    await _audioPlayer.stop();
    await _disposeVideo();

    final controller = source.startsWith('assets/')
        ? VideoPlayerController.asset(source)
        : VideoPlayerController.networkUrl(Uri.parse(source));

    await controller.initialize();
    controller.setLooping(false);
    _videoController = controller;
    videoControllerNotifier.value = controller;
    controller.addListener(_onVideoTick);

    if (_currentContent != null) {
      mediaItem.add(_toMediaItem(_currentContent!));
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
    _previewTimer?.cancel();
    if (_kind == MediaKind.video) {
      await _disposeVideo();
    } else {
      await _audioPlayer.stop();
    }
    previewExpiredNotifier.value = false;
    _currentContent = null;
    sessionActiveNotifier.value = false;
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
    await _audioPlayer.dispose();
    await _disposeVideo();
  }
}
