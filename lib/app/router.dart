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
import 'package:kikikaikai/features/profile/profile_screen.dart';
import 'package:kikikaikai/features/subscription/upgrade_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorBrowseKey =
    GlobalKey<NavigatorState>(debugLabel: 'browse');
final _shellNavigatorSearchKey =
    GlobalKey<NavigatorState>(debugLabel: 'search');
final _shellNavigatorSavedKey =
    GlobalKey<NavigatorState>(debugLabel: 'saved');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/welcome',
    redirect: (context, state) {
      if (state.uri.path == '/home') return '/browse';
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
        path: '/mypage',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/content/:id',
        builder: (context, state) => ContentDetailScreen(
          contentId: state.pathParameters['id']!,
        ),
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
            navigatorKey: _shellNavigatorBrowseKey,
            routes: [
              GoRoute(
                path: '/browse',
                builder: (context, state) => MainShellBranch.browse(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSearchKey,
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => MainShellBranch.search(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSavedKey,
            routes: [
              GoRoute(
                path: '/saved',
                builder: (context, state) => MainShellBranch.saved(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
