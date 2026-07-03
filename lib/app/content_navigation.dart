import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// コンテンツ詳細への遷移とパス判定
abstract final class ContentNavigation {
  static void openDetail(BuildContext context, String contentId) {
    final path = _currentPath(context) ?? '/home';
    openDetailWithPath(GoRouter.of(context), path, contentId);
  }

  static void openDetailWithPath(
    GoRouter router,
    String currentPath,
    String contentId,
  ) {
    if (currentPath.startsWith('/search')) {
      router.push('/search/content/$contentId');
      return;
    }
    if (currentPath.startsWith('/mypage')) {
      router.push('/mypage/content/$contentId');
      return;
    }
    final figureId = figureIdFromPath(currentPath);
    if (figureId != null) {
      router.push('/home/figure/$figureId/content/$contentId');
      return;
    }
    router.push('/home/content/$contentId');
  }

  static String? figureIdFromPath(String path) {
    return RegExp(r'/figure/([^/]+)').firstMatch(path)?.group(1);
  }

  static bool isContentDetailPath(String path) {
    return RegExp(r'/content/[^/]+$').hasMatch(path);
  }

  static String? detailContentIdFromPath(String path) {
    return RegExp(r'/content/([^/]+)$').firstMatch(path)?.group(1);
  }

  static bool isDetailPath(String path, String contentId) {
    return path == '/content/$contentId' || path.endsWith('/content/$contentId');
  }

  static bool isUnderMainShell(String path) {
    return path == '/home' ||
        path == '/search' ||
        path == '/mypage' ||
        path.startsWith('/home/') ||
        path.startsWith('/search/') ||
        path.startsWith('/mypage/');
  }

  static String? _currentPath(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    if (router == null) return null;
    return currentRouterPath(router);
  }

  /// Shell 配下の子ルートも含む現在パス。
  /// 起動直後は `router.state` が未初期化のため、複数ソースを安全に参照する。
  static String currentRouterPath(GoRouter router) {
    String? configPath;
    String? statePath;

    final config = router.routerDelegate.currentConfiguration;
    if (config.matches.isNotEmpty) {
      if (config.uri.path.isNotEmpty) {
        configPath = config.uri.path;
      }
      try {
        final path = router.state.uri.path;
        if (path.isNotEmpty) {
          statePath = path;
        }
      } on StateError {
        // RouteMatchList が空の瞬間がある。
      }
    }

    final routeInfoPath = router.routeInformationProvider.value.uri.path;

    for (final candidate in [statePath, configPath, routeInfoPath]) {
      if (candidate != null && candidate.contains('/content/')) {
        return candidate;
      }
    }

    for (final candidate in [routeInfoPath, statePath, configPath]) {
      if (candidate != null && candidate.isNotEmpty) {
        return candidate;
      }
    }

    return '/welcome';
  }
}
