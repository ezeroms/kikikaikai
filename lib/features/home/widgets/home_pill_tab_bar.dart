import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/features/home/home_tab.dart';

class HomePillTabBar extends StatelessWidget {
  const HomePillTabBar({
    super.key,
    required this.controller,
  });

  final TabController controller;

  static const height = 56.0;

  static const _activeOpacity = 1.0;
  static const _inactiveOpacity = 0.42;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        labelPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 2,
        indicatorColor: AppColors.onBase.withValues(alpha: _activeOpacity),
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelColor: AppColors.onBase.withValues(alpha: _activeOpacity),
        unselectedLabelColor:
            AppColors.onBase.withValues(alpha: _inactiveOpacity),
        labelStyle: AppTypography.label(
          size: 16,
          weight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.label(
          size: 16,
          weight: FontWeight.w500,
        ),
        tabs: [
          for (final tab in HomeTab.values) Tab(text: tab.label),
        ],
      ),
    );
  }
}
