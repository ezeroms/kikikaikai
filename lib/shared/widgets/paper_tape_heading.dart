import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';

class PaperTapeHeading extends StatelessWidget {
  const PaperTapeHeading({
    super.key,
    required this.title,
    this.date,
    this.isOdd = true,
  });

  final String title;
  final String? date;
  final bool isOdd;

  @override
  Widget build(BuildContext context) {
    final bgColor = isOdd ? AppColors.summerWood : AppColors.riverRoad;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Transform.rotate(
        angle: isOdd ? -0.01 : 0.015,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor.withValues(alpha: 0.85),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.body(
                    size: 15,
                    color: AppColors.black,
                  ),
                ),
              ),
              if (date != null)
                Text(
                  date!,
                  style: AppTypography.label(
                    size: 12,
                    color: AppColors.black.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
