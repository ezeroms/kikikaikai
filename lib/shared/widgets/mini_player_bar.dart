import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kikikaikai/app/content_navigation.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/media/kikikaikai_media_handler.dart';
import 'package:kikikaikai/core/media/media_playback.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/features/content/widgets/fullscreen_video_page.dart';
import 'package:kikikaikai/shared/widgets/circular_media_button.dart';
import 'package:video_player/video_player.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({
    super.key,
    required this.currentPath,
    required this.router,
  });

  final String currentPath;
  final GoRouter router;

  static const _horizontalPadding = 12.0;
  static const _verticalPadding = 8.0;
  static const _thumbHeight = 52.0;
  static const _thumbAspectRatio = 16 / 9;
  static const _thumbWidth = _thumbHeight * _thumbAspectRatio;

  static const _progressHeight = 3.0;

  static const height = _verticalPadding * 2 + _thumbHeight + _progressHeight;

  double _playbackRatio(KikikaikaiMediaHandler handler, PlaybackState? state) {
    if (state == null) return 0;
    final duration = handler.mediaItem.value?.duration;
    if (duration == null || duration.inMilliseconds <= 0) return 0;
    final positionMs = state.updatePosition.inMilliseconds;
    return (positionMs / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  bool _isOnSameContentDetail(String contentId) {
    return ContentNavigation.isDetailPath(currentPath, contentId);
  }

  void _openDetail(String contentId) {
    ContentNavigation.openDetailWithPath(router, currentPath, contentId);
  }

  @override
  Widget build(BuildContext context) {
    final handler = MediaPlayback.handler;
    if (handler == null) return const SizedBox.shrink();

    return ValueListenableBuilder<bool>(
      valueListenable: handler.sessionActiveNotifier,
      builder: (context, active, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: handler.fullscreenVideoNotifier,
          builder: (context, fullscreen, _) {
            return ValueListenableBuilder<Content?>(
              valueListenable: handler.currentContentNotifier,
              builder: (context, content, _) {
                if (!active || content == null || fullscreen) {
                  return const SizedBox.shrink();
                }
                if (_isOnSameContentDetail(content.id)) {
                  return const SizedBox.shrink();
                }

                return Material(
              color: AppColors.surface,
              elevation: 8,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.border),
                  ),
                ),
                child: SizedBox(
                  height: height,
                  child: StreamBuilder<PlaybackState>(
                    stream: handler.playbackState,
                    builder: (context, snapshot) {
                      final playing = snapshot.data?.playing ?? false;
                      final progress = _playbackRatio(handler, snapshot.data);

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              _horizontalPadding,
                              _verticalPadding,
                              _horizontalPadding,
                              _verticalPadding + _progressHeight,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _MiniPlayerThumbnail(
                                  content: content,
                                  handler: handler,
                                  width: _thumbWidth,
                                  height: _thumbHeight,
                                  onOpenDetail: () => _openDetail(content.id),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SizedBox(
                                    height: _thumbHeight,
                                    child: ClipRect(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _openDetail(content.id),
                                          borderRadius: BorderRadius.circular(6),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              alignment: Alignment.centerLeft,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    content.title,
                                                    style: AppTypography
                                                        .titleSmall(size: 13)
                                                        .copyWith(height: 1.1),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    content.type.label,
                                                    style: AppTypography.body(
                                                      size: 11,
                                                      color: AppColors.muted,
                                                      weight: FontWeight.w400,
                                                    ).copyWith(height: 1.1),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                CircularMediaButton.mini(
                                  playing: playing,
                                  onPressed: () {
                                    if (playing) {
                                      handler.pause();
                                    } else {
                                      handler.play();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: _progressHeight,
                            child: LinearProgressIndicator(
                              minHeight: _progressHeight,
                              value: progress,
                              backgroundColor:
                                  AppColors.onBase.withValues(alpha: 0.18),
                              color: AppColors.onBase,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
              },
            );
          },
        );
      },
    );
  }
}

class _MiniPlayerThumbnail extends StatelessWidget {
  const _MiniPlayerThumbnail({
    required this.content,
    required this.handler,
    required this.width,
    required this.height,
    required this.onOpenDetail,
  });

  final Content content;
  final KikikaikaiMediaHandler handler;
  final double width;
  final double height;
  final VoidCallback onOpenDetail;

  void _openFullscreen(BuildContext context, VideoPlayerController controller) {
    openFullscreenVideo(
      context,
      controller: controller,
      title: content.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (handler.kind != MediaKind.video) {
      return InkWell(
        onTap: onOpenDetail,
        child: _ThumbnailFrame(
          width: width,
          height: height,
          child: Image.asset(
            key: ValueKey(content.id),
            content.displayThumbnail,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return ValueListenableBuilder<VideoPlayerController?>(
      valueListenable: handler.videoControllerNotifier,
      builder: (context, controller, _) {
        final initialized =
            controller != null && controller.value.isInitialized;

        return GestureDetector(
          onTap: controller != null
              ? () => _openFullscreen(context, controller)
              : onOpenDetail,
          behavior: HitTestBehavior.opaque,
          child: _ThumbnailFrame(
            width: width,
            height: height,
            child: IgnorePointer(
              child: initialized
                  ? FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    )
                  : Image.asset(
                      content.displayThumbnail,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _ThumbnailFrame extends StatelessWidget {
  const _ThumbnailFrame({
    required this.width,
    required this.height,
    required this.child,
  });

  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: width,
        height: height,
        child: child,
      ),
    );
  }
}

/// ミニプレーヤー表示時のスクロール余白（タブ内リスト用）
double miniPlayerScrollPadding(BuildContext context) {
  final handler = MediaPlayback.handler;
  if (handler == null || !handler.sessionActiveNotifier.value) return 0;

  final content = handler.currentContent;
  if (content == null) return 0;

  final router = GoRouter.maybeOf(context);
  final path = router?.state.uri.path ?? '';
  if (ContentNavigation.isDetailPath(path, content.id)) return 0;

  return MiniPlayerBar.height;
}

/// ミニプレーヤーのオーバーレイ位置（MaterialApp.builder 用）
double miniPlayerOverlayBottom(String path, BuildContext context) {
  final padding = MediaQuery.paddingOf(context).bottom;
  if (ContentNavigation.isUnderMainShell(path)) {
    return kBottomNavigationBarHeight + padding;
  }
  return padding;
}
