import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/media/format_media_duration.dart';
import 'package:kikikaikai/core/media/media_playback.dart';
import 'package:kikikaikai/shared/widgets/inline_video_play_button.dart';
import 'package:kikikaikai/shared/widgets/media_player_controls.dart';
import 'package:video_player/video_player.dart';

Future<void> openFullscreenVideo(
  BuildContext context, {
  required VideoPlayerController controller,
  required String title,
}) async {
  final handler = MediaPlayback.handler;
  handler?.fullscreenVideoNotifier.value = true;
  try {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => FullscreenVideoPage(
          controller: controller,
          title: title,
        ),
      ),
    );
  } finally {
    handler?.fullscreenVideoNotifier.value = false;
  }
}

class FullscreenVideoPage extends StatefulWidget {
  const FullscreenVideoPage({
    super.key,
    required this.controller,
    required this.title,
  });

  final VideoPlayerController controller;
  final String title;

  @override
  State<FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<FullscreenVideoPage> {
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    widget.controller.addListener(_onVideoUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onVideoUpdate);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  void _onVideoUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final handler = MediaPlayback.handler;
    final value = widget.controller.value;
    final position = value.position;
    final total = value.duration;
    final progress = total.inMilliseconds > 0
        ? position.inMilliseconds / total.inMilliseconds
        : 0.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: value.isInitialized
                  ? AspectRatio(
                      aspectRatio: value.aspectRatio,
                      child: VideoPlayer(widget.controller),
                    )
                  : const CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
            ),
            AnimatedOpacity(
              opacity: _showControls ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              LucideIcons.minimize,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Text(
                              widget.title,
                              style: AppTypography.body(size: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: Column(
                          children: [
                            MediaPlayerSeekBar(
                              position: position,
                              total: total,
                              progress: progress.clamp(0.0, 1.0),
                              onChanged: total.inMilliseconds > 0
                                  ? (v) {
                                      handler?.seek(
                                        Duration(
                                          milliseconds:
                                              (total.inMilliseconds * v).round(),
                                        ),
                                      );
                                    }
                                  : null,
                            ),
                            if (handler != null) ...[
                              const SizedBox(height: 12),
                              ValueListenableBuilder<bool>(
                                valueListenable: handler.previewExpiredNotifier,
                                builder: (context, previewExpired, _) {
                                  return MediaPlayerTransportRow(
                                    handler: handler,
                                    playing: value.isPlaying,
                                    position: position,
                                    previewExpiredMessage: previewExpired
                                        ? 'プレビューは30秒までです'
                                        : null,
                                    onPlayPause: () {
                                      if (value.isPlaying) {
                                        handler.pause();
                                      } else {
                                        handler.play();
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InlineVideoPlayer extends StatefulWidget {
  const InlineVideoPlayer({
    super.key,
    required this.controller,
    required this.title,
    this.onFullscreenTap,
  });

  final VideoPlayerController controller;
  final String title;
  final VoidCallback? onFullscreenTap;

  @override
  State<InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<InlineVideoPlayer>
    with SingleTickerProviderStateMixin {
  static const _controlsFadeDuration = Duration(milliseconds: 550);
  static const _controlsVisibleDuration = Duration(seconds: 5);

  late final AnimationController _controlsFadeController;
  late final Animation<double> _controlsFadeAnimation;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onVideoUpdate);
    _controlsFadeController = AnimationController(
      vsync: this,
      duration: _controlsFadeDuration,
      reverseDuration: _controlsFadeDuration,
      value: 1,
    );
    _controlsFadeAnimation = CurvedAnimation(
      parent: _controlsFadeController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _scheduleControlsHide();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controlsFadeController.dispose();
    widget.controller.removeListener(_onVideoUpdate);
    super.dispose();
  }

  void _onVideoUpdate() {
    if (mounted) setState(() {});
  }

  void _scheduleControlsHide() {
    _hideControlsTimer?.cancel();
    if (!widget.controller.value.isPlaying) return;
    _hideControlsTimer = Timer(_controlsVisibleDuration, () {
      if (!mounted || !widget.controller.value.isPlaying) return;
      _fadeOutControls();
    });
  }

  Future<void> _fadeInControls() async {
    _hideControlsTimer?.cancel();
    if (_controlsFadeController.value >= 1 &&
        !_controlsFadeController.isAnimating) {
      _scheduleControlsHide();
      return;
    }
    await _controlsFadeController.forward();
    if (mounted) {
      _scheduleControlsHide();
    }
  }

  Future<void> _fadeOutControls() async {
    _hideControlsTimer?.cancel();
    if (_controlsFadeController.value <= 0 &&
        !_controlsFadeController.isAnimating) {
      return;
    }
    await _controlsFadeController.reverse();
  }

  void _togglePlayPause() {
    final handler = MediaPlayback.handler;
    if (handler == null) return;

    if (widget.controller.value.isPlaying) {
      handler.pause();
      _hideControlsTimer?.cancel();
      unawaited(_fadeInControls());
      return;
    }

    handler.play();
    unawaited(_fadeInControls());
  }

  void _showControlsOverlay() {
    unawaited(_fadeInControls());
  }

  void _hideControlsOverlay() {
    unawaited(_fadeOutControls());
  }

  void _openFullscreen() {
    if (widget.onFullscreenTap != null) {
      widget.onFullscreenTap!();
      return;
    }
    openFullscreenVideo(
      context,
      controller: widget.controller,
      title: widget.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final handler = MediaPlayback.handler;
    final value = widget.controller.value;
    final position = value.position;
    final total = value.duration;
    final progress = total.inMilliseconds > 0
        ? position.inMilliseconds / total.inMilliseconds
        : 0.0;

    return AspectRatio(
      aspectRatio: value.aspectRatio,
      child: ColoredBox(
        color: Colors.black,
        child: AnimatedBuilder(
          animation: _controlsFadeController,
          builder: (context, _) {
            final controlsHidden = _controlsFadeController.value == 0 &&
                !_controlsFadeController.isAnimating;

            return Stack(
              fit: StackFit.expand,
              children: [
                VideoPlayer(widget.controller),
                if (controlsHidden)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _showControlsOverlay,
                      behavior: HitTestBehavior.translucent,
                    ),
                  ),
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: _controlsFadeController.value < 0.05,
                    child: FadeTransition(
                      opacity: _controlsFadeAnimation,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: _hideControlsOverlay,
                              behavior: HitTestBehavior.translucent,
                              child: ColoredBox(
                                color: Colors.black.withValues(alpha: 0.45),
                              ),
                            ),
                          ),
                          Center(
                            child: InlineVideoPlayButton(
                              playing: value.isPlaying,
                              onPressed: _togglePlayPause,
                            ),
                          ),
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 20,
                            child: Row(
                              children: [
                                Text(
                                  '${formatPlayerClockHms(position)} / '
                                  '${formatPlayerClockHms(total)}',
                                  style: AppTypography.label(
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: _openFullscreen,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 40,
                                  ),
                                  icon: const Icon(
                                    LucideIcons.maximize,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 5,
                                ),
                                overlayShape: SliderComponentShape.noOverlay,
                                activeTrackColor: AppColors.primary,
                                inactiveTrackColor:
                                    Colors.white.withValues(alpha: 0.35),
                              ),
                              child: Slider(
                                padding: EdgeInsets.zero,
                                value: progress.clamp(0.0, 1.0),
                                onChanged: total.inMilliseconds > 0
                                    ? (v) {
                                        handler?.seek(
                                          Duration(
                                            milliseconds: (total.inMilliseconds *
                                                    v)
                                                .round(),
                                          ),
                                        );
                                        _scheduleControlsHide();
                                      }
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
