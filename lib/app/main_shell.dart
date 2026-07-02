import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/core/media/media_playback.dart';
import 'package:kikikaikai/features/home/home_screen.dart';
import 'package:kikikaikai/features/profile/account_tab_screen.dart';
import 'package:kikikaikai/features/search/search_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;
    final handler = MediaPlayback.handler;

    if (handler == null) {
      return _buildScaffold(currentIndex, showBottomNav: true);
    }

    return ValueListenableBuilder<bool>(
      valueListenable: handler.fullscreenVideoNotifier,
      builder: (context, fullscreen, _) {
        return _buildScaffold(currentIndex, showBottomNav: !fullscreen);
      },
    );
  }

  Widget _buildScaffold(int currentIndex, {required bool showBottomNav}) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: showBottomNav
          ? BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: navigationShell.goBranch,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    LucideIcons.house,
                    color: currentIndex == 0
                        ? AppColors.onBase
                        : AppColors.muted,
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    LucideIcons.search,
                    color: currentIndex == 1
                        ? AppColors.onBase
                        : AppColors.muted,
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    LucideIcons.circle_user,
                    color: currentIndex == 2
                        ? AppColors.onBase
                        : AppColors.muted,
                  ),
                  label: '',
                ),
              ],
            )
          : null,
    );
  }
}

class MainShellBranch {
  static Widget home() => const HomeScreen();
  static Widget search() => const SearchScreen();
  static Widget mypage() => const AccountTabScreen();
}
