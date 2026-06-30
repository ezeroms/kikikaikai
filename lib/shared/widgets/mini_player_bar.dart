import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/media/kikikaikai_media_handler.dart';
import 'package:kikikaikai/core/media/media_playback.dart';
import 'package:kikikaikai/features/content/widgets/fullscreen_video_page.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key, required this.currentPath});

  final String currentPath;

  static const height = 72.0;

  bool _isOnSameContentDetail(String contentId) {
    return currentPath == '/content/$contentId';
  }

  @override
  Widget build(BuildContext context) {
    final handler = MediaPlayback.handler;
    if (handler == null) return const SizedBox.shrink();

    return ValueListenableBuilder<bool>(
      valueListenable: handler.sessionActiveNotifier,
      builder: (context, active, _) {
        final content = handler.currentContent;
        if (!active || content == null) return const SizedBox.shrink();
        if (_isOnSameContentDetail(content.id)) {
          return const SizedBox.shrink();
        }

        return Material(
          color: AppColors.cardSurface,
          elevation: 8,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.cardBorder),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: height,
                child: StreamBuilder<PlaybackState>(
                  stream: handler.playbackState,
                  builder: (context, snapshot) {
                    final playing = snapshot.data?.playing ?? false;
                    return Row(
                      children: [
                        InkWell(
                          onTap: () => context.push('/content/${content.id}'),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.asset(
                                  content.displayThumbnail,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.38,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      content.type.label,
                                      style: AppTypography.label(
                                        size: 10,
                                        color: AppColors.mangoTango,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      content.title,
                                      style: AppTypography.body(size: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            playing ? LucideIcons.pause : LucideIcons.play,
                            color: AppColors.mangoTango,
                          ),
                          onPressed: () {
                            if (playing) {
                              handler.pause();
                            } else {
                              handler.play();
                            }
                          },
                        ),
                        if (handler.kind == MediaKind.video)
                          IconButton(
                            icon: const Icon(
                              LucideIcons.maximize,
                              color: AppColors.summerWood,
                            ),
                            onPressed: () {
                              final controller =
                                  handler.videoControllerNotifier.value;
                              if (controller != null &&
                                  controller.value.isInitialized) {
                                openFullscreenVideo(
                                  context,
                                  controller: controller,
                                  title: content.title,
                                );
                              }
                            },
                          ),
                        IconButton(
                          icon: const Icon(
                            LucideIcons.x,
                            color: AppColors.shuttleGray,
                          ),
                          onPressed: () => MediaPlayback.stop(),
                        ),
                        const SizedBox(width: 4),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ミニプレーヤー表示時のスクロール余白（タブ内リスト用）
double miniPlayerScrollPadding(BuildContext context) {
  final handler = MediaPlayback.handler;
  if (handler == null || !handler.sessionActiveNotifier.value) return 0;

  final content = handler.currentContent;
  if (content == null) return 0;

  final path = GoRouterState.of(context).uri.path;
  if (path == '/content/${content.id}') return 0;

  return MiniPlayerBar.height;
}

/// ミニプレーヤーのオーバーレイ位置（MaterialApp.builder 用）
double miniPlayerOverlayBottom(String path, BuildContext context) {
  final padding = MediaQuery.paddingOf(context).bottom;
  if (['/browse', '/search', '/saved'].contains(path)) {
    return kBottomNavigationBarHeight + padding;
  }
  return padding;
}
