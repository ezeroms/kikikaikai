import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/shared/widgets/danchi_home_background.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DanchiHomeBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                Image.asset(
                  'assets/branding/logo_horizontal.png',
                  height: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  '奇奇怪怪',
                  style: AppTypography.heading(size: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  '闇市の団地、品品団地です。\nご入居お待ちしています。',
                  style: AppTypography.body(
                    size: 15,
                    color: AppColors.summerWood,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/signup'),
                    child: const Text('入居する'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.push('/login'),
                    child: const Text('ログイン'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/browse'),
                  child: Text(
                    'とりあえず見学',
                    style: AppTypography.body(color: AppColors.shuttleGray),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
