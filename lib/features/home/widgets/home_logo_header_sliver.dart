import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';

/// 鑑賞画面上部のロゴ。固定サイズのままスクロールで上に隠れる。
class HomeLogoHeader extends StatelessWidget {
  const HomeLogoHeader({super.key});

  static const height = 96.0;
  static const logoHeight = 80.0;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.base,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Center(
          child: Image.asset(
            'assets/branding/pinpin/logo.png',
            height: logoHeight,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
