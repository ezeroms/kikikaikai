import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kikikaikai/app/main_shell.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/features/auth/login_screen.dart';
import 'package:kikikaikai/features/auth/signup_screen.dart';
import 'package:kikikaikai/features/auth/welcome_screen.dart';
import 'package:kikikaikai/features/content/content_detail_screen.dart';
import 'package:kikikaikai/features/content/content_list_screen.dart';
import 'package:kikikaikai/features/downloads/downloads_screen.dart';
import 'package:kikikaikai/features/figure/figure_contents_screen.dart';
import 'package:kikikaikai/features/subscription/upgrade_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorSearchKey =
    GlobalKey<NavigatorState>(debugLabel: 'search');
final _shellNavigatorMypageKey =
    GlobalKey<NavigatorState>(debugLabel: 'mypage');

GoRoute _contentDetailRoute() {
  return GoRoute(
    path: 'content/:contentId',
    pageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: ContentDetailScreen(
        contentId: state.pathParameters['contentId']!,
      ),
    ),
  );
}

GoRoute _figureContentsRoute() {
  return GoRoute(
    path: 'figure/:figureId',
    builder: (context, state) => FigureContentsScreen(
      figureId: state.pathParameters['figureId']!,
    ),
    routes: [_contentDetailRoute()],
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/welcome',
    redirect: (context, state) {
      if (state.uri.path == '/browse') return '/home';
      if (state.uri.path == '/saved') return '/mypage';
      final legacyDetail = RegExp(r'^/content/([^/]+)$').firstMatch(state.uri.path);
      if (legacyDetail != null) {
        return '/home/content/${legacyDetail.group(1)}';
      }
      final legacyFigure = RegExp(r'^/figure/([^/]+)(.*)$').firstMatch(state.uri.path);
      if (legacyFigure != null) {
        return '/home/figure/${legacyFigure.group(1)}${legacyFigure.group(2)}';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/upgrade',
        builder: (context, state) => const UpgradeScreen(),
      ),
      GoRoute(
        path: '/downloads',
        builder: (context, state) => const DownloadsScreen(),
      ),
      GoRoute(
        path: '/kairanban',
        builder: (context, state) =>
            const ContentListScreen(type: ContentType.bulletin),
      ),
      GoRoute(
        path: '/gyokko',
        builder: (context, state) =>
            const ContentListScreen(type: ContentType.manuscript),
      ),
      GoRoute(
        path: '/gaitotv',
        builder: (context, state) =>
            const ContentListScreen(type: ContentType.video),
      ),
      GoRoute(
        path: '/gaitoradio',
        builder: (context, state) =>
            const ContentListScreen(type: ContentType.audio),
      ),
      GoRoute(
        path: '/kikikaikai',
        builder: (context, state) =>
            const ContentListScreen(type: ContentType.kikikaikai),
      ),
      GoRoute(
        path: '/danchiletter',
        builder: (context, state) =>
            const ContentListScreen(type: ContentType.shop),
      ),
      GoRoute(
        path: '/kyusakusoko',
        builder: (context, state) =>
            const ContentListScreen(type: ContentType.archive),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => MainShellBranch.home(),
                routes: [
                  _contentDetailRoute(),
                  _figureContentsRoute(),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSearchKey,
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => MainShellBranch.search(),
                routes: [_contentDetailRoute()],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorMypageKey,
            routes: [
              GoRoute(
                path: '/mypage',
                builder: (context, state) => MainShellBranch.mypage(),
                routes: [_contentDetailRoute()],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
