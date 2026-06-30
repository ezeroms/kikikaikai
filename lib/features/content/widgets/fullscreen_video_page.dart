import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/media/media_playback.dart';
import 'package:video_player/video_player.dart';

Future<void> openFullscreenVideo(
  BuildContext context, {
  required VideoPlayerController controller,
  required String title,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) => FullscreenVideoPage(
        controller: controller,
        title: title,
      ),
    ),
  );
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

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
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
                      color: AppColors.mangoTango,
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Slider(
                              value: progress.clamp(0.0, 1.0),
                              onChanged: total.inMilliseconds > 0
                                  ? (v) {
                                      handler?.seek(
                                        Duration(
                                          milliseconds:
                                              (total.inMilliseconds * v)
                                                  .round(),
                                        ),
                                      );
                                    }
                                  : null,
                              activeColor: AppColors.mangoTango,
                              inactiveColor: AppColors.shuttleGray,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: AppTypography.label(size: 11),
                                ),
                                Text(
                                  _formatDuration(total),
                                  style: AppTypography.label(size: 11),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  iconSize: 36,
                                  onPressed: () => handler?.seek(
                                    position - const Duration(seconds: 15),
                                  ),
                                  icon: const Icon(
                                    LucideIcons.rotate_ccw,
                                    color: AppColors.summerWood,
                                  ),
                                ),
                                IconButton(
                                  iconSize: 52,
                                  onPressed: () {
                                    if (value.isPlaying) {
                                      handler?.pause();
                                    } else {
                                      handler?.play();
                                    }
                                  },
                                  icon: Icon(
                                    value.isPlaying
                                        ? LucideIcons.pause
                                        : LucideIcons.play,
                                    color: AppColors.mangoTango,
                                  ),
                                ),
                                IconButton(
                                  iconSize: 36,
                                  onPressed: () => handler?.seek(
                                    position + const Duration(seconds: 15),
                                  ),
                                  icon: const Icon(
                                    LucideIcons.rotate_cw,
                                    color: AppColors.summerWood,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
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

class InlineVideoPlayer extends StatelessWidget {
  const InlineVideoPlayer({
    super.key,
    required this.controller,
    required this.title,
  });

  final VideoPlayerController controller;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: () => openFullscreenVideo(
                context,
                controller: controller,
                title: title,
              ),
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  LucideIcons.maximize,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
