import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/features/home/home_screen.dart';
import 'package:kikikaikai/features/saved/saved_screen.dart';
import 'package:kikikaikai/features/search/search_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: navigationShell.goBranch,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              LucideIcons.house,
              color: navigationShell.currentIndex == 0
                  ? AppColors.mangoTango
                  : AppColors.shuttleGray,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              LucideIcons.search,
              color: navigationShell.currentIndex == 1
                  ? AppColors.mangoTango
                  : AppColors.shuttleGray,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              LucideIcons.bookmark,
              color: navigationShell.currentIndex == 2
                  ? AppColors.mangoTango
                  : AppColors.shuttleGray,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}

class MainShellBranch {
  static Widget browse() => const HomeScreen();
  static Widget search() => const SearchScreen();
  static Widget saved() => const SavedScreen();
}
