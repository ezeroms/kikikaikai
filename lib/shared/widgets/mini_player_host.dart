import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kikikaikai/app/content_navigation.dart';
import 'package:kikikaikai/core/debug/playback_debug_log.dart';
import 'package:kikikaikai/core/media/media_playback.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/providers/detail_mini_player_provider.dart';
import 'package:kikikaikai/shared/widgets/mini_player_bar.dart';

class MiniPlayerHost extends ConsumerStatefulWidget {
  const MiniPlayerHost({
    super.key,
    required this.router,
    required this.child,
  });

  final GoRouter router;
  final Widget? child;

  @override
  ConsumerState<MiniPlayerHost> createState() => _MiniPlayerHostState();
}

class _MiniPlayerHostState extends ConsumerState<MiniPlayerHost> {
  late String _path;
  bool? _lastLoggedVisible;
  String? _lastLoggedPath;

  @override
  void initState() {
    super.initState();
    _path = ContentNavigation.currentRouterPath(widget.router);
    widget.router.routerDelegate.addListener(_onRouteChanged);
  }

  @override
  void didUpdateWidget(covariant MiniPlayerHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.router != widget.router) {
      oldWidget.router.routerDelegate.removeListener(_onRouteChanged);
      widget.router.routerDelegate.addListener(_onRouteChanged);
      _path = ContentNavigation.currentRouterPath(widget.router);
    }
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    final next = ContentNavigation.currentRouterPath(widget.router);
    if (next == _path || !mounted) return;
    setState(() => _path = next);
  }

  bool _isOnDetailForContent({
    required WidgetRef ref,
    required String path,
    required String contentId,
  }) {
    final activeDetailId = ref.watch(detailScreenContentIdProvider);
    if (activeDetailId == contentId) {
      return true;
    }
    return ContentNavigation.detailContentIdFromPath(path) == contentId;
  }

  bool _isMiniPlayerVisible({
    required WidgetRef ref,
    required String path,
    required bool active,
    required bool fullscreen,
    required Content? content,
  }) {
    if (!active || content == null || fullscreen) {
      PlaybackDebugLog.log(
        'MiniPlayerHost',
        'hidden: active=$active content=${content?.id} fullscreen=$fullscreen',
      );
      return false;
    }

    final onDetailForPlayingContent = _isOnDetailForContent(
      ref: ref,
      path: path,
      contentId: content.id,
    );

    if (onDetailForPlayingContent) {
      final providerVisible = ref.watch(detailMiniPlayerVisibleProvider);
      final activeDetailId = ref.read(detailScreenContentIdProvider);
      _logVisibilityIfChanged(
        visible: providerVisible,
        path: path,
        message:
            'detail activeDetailId=$activeDetailId playing=${content.id} '
            'providerVisible=$providerVisible',
      );
      return providerVisible;
    }

    _logVisibilityIfChanged(
      visible: true,
      path: path,
      message: 'default playing=${content.id}',
    );
    return true;
  }

  void _logVisibilityIfChanged({
    required bool visible,
    required String path,
    required String message,
  }) {
    if (_lastLoggedVisible == visible && _lastLoggedPath == path) return;
    _lastLoggedVisible = visible;
    _lastLoggedPath = path;
    PlaybackDebugLog.log('MiniPlayerHost', 'path=$path $message');
  }

  @override
  Widget build(BuildContext context) {
    final handler = MediaPlayback.handler;
    final path = ContentNavigation.currentRouterPath(widget.router);
    if (path != _path) {
      _path = path;
    }

    return Stack(
      children: [
        ?widget.child,
        Positioned(
          left: 0,
          right: 0,
          bottom: miniPlayerOverlayBottom(path, context),
          child: handler == null
              ? const SizedBox.shrink()
              : ValueListenableBuilder<bool>(
                  valueListenable: handler.sessionActiveNotifier,
                  builder: (context, active, _) {
                    return ValueListenableBuilder<bool>(
                      valueListenable: handler.fullscreenVideoNotifier,
                      builder: (context, fullscreen, _) {
                        return ValueListenableBuilder<Content?>(
                          valueListenable: handler.currentContentNotifier,
                          builder: (context, content, _) {
                            final visible = _isMiniPlayerVisible(
                              ref: ref,
                              path: path,
                              active: active,
                              fullscreen: fullscreen,
                              content: content,
                            );

                            return ClipRect(
                              clipBehavior: Clip.hardEdge,
                              child: AnimatedSlide(
                                offset: visible
                                    ? Offset.zero
                                    : const Offset(0, 1),
                                duration: Duration(
                                  milliseconds: visible ? 340 : 220,
                                ),
                                curve: visible
                                    ? Curves.easeOutBack
                                    : Curves.easeInCubic,
                                child: IgnorePointer(
                                  ignoring: !visible,
                                  child: MiniPlayerBar(
                                    currentPath: path,
                                    router: widget.router,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
