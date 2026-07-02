import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kikikaikai/shared/widgets/mini_player_bar.dart';

String currentRouterPath(GoRouter router) {
  final config = router.routerDelegate.currentConfiguration;
  if (config.isEmpty) {
    return router.routeInformationProvider.value.uri.path;
  }
  return config.uri.path;
}

class MiniPlayerHost extends StatefulWidget {
  const MiniPlayerHost({
    super.key,
    required this.router,
    required this.child,
  });

  final GoRouter router;
  final Widget? child;

  @override
  State<MiniPlayerHost> createState() => _MiniPlayerHostState();
}

class _MiniPlayerHostState extends State<MiniPlayerHost> {
  late String _path;

  @override
  void initState() {
    super.initState();
    _path = currentRouterPath(widget.router);
    widget.router.routerDelegate.addListener(_onRouteChanged);
  }

  @override
  void didUpdateWidget(covariant MiniPlayerHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.router != widget.router) {
      oldWidget.router.routerDelegate.removeListener(_onRouteChanged);
      widget.router.routerDelegate.addListener(_onRouteChanged);
      _path = currentRouterPath(widget.router);
    }
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    final next = currentRouterPath(widget.router);
    if (next == _path || !mounted) return;
    setState(() => _path = next);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ?widget.child,
        Positioned(
          left: 0,
          right: 0,
          bottom: miniPlayerOverlayBottom(_path, context),
          child: MiniPlayerBar(currentPath: _path, router: widget.router),
        ),
      ],
    );
  }
}
