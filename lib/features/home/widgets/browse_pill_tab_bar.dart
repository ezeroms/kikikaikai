import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/features/home/browse_tab.dart';

class BrowsePillTabBar extends StatelessWidget {
  const BrowsePillTabBar({
    super.key,
    required this.controller,
  });

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            itemCount: BrowseTab.values.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final tab = BrowseTab.values[index];
              final selected = controller.index == index;
              return _PillTab(
                tab: tab,
                selected: selected,
                onTap: () => controller.animateTo(index),
              );
            },
          );
        },
      ),
    );
  }
}

class _PillTab extends StatelessWidget {
  const _PillTab({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final BrowseTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.white : AppColors.cardSurface,
            borderRadius: BorderRadius.circular(999),
            border: selected
                ? null
                : Border.all(color: AppColors.cardBorder, width: 0.5),
          ),
          child: Text(
            tab.label,
            style: AppTypography.label(
              size: 15,
              weight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? AppColors.black : AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
