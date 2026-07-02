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
    router.push('/home/content/$contentId');
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
    return GoRouter.maybeOf(context)?.state.uri.path;
  }
}
