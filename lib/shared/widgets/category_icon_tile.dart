import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';

class CategoryIconTile extends StatelessWidget {
  const CategoryIconTile({
    super.key,
    required this.iconAsset,
    required this.label,
    required this.onTap,
  });

  final String iconAsset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconAsset,
            width: 72,
            height: 72,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.label(size: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
