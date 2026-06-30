import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/models/user_tier.dart';
import 'package:kikikaikai/core/providers/providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/branding/eye_catch/mypage.png',
              width: 28,
              height: 28,
            ),
            const SizedBox(width: 8),
            const Text('自室'),
          ],
        ),
      ),
      body: authAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (user) {
          final tier = user?.tier ?? UserTier.guest;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    'assets/branding/eye_catch/mypage.png',
                    width: 96,
                    height: 96,
                  ),
                ),
                const SizedBox(height: 24),
                if (user != null) ...[
                  Text(
                    user.displayName,
                    style: AppTypography.heading(size: 24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: AppTypography.label(),
                    textAlign: TextAlign.center,
                  ),
                ] else
                  Text(
                    '見学者',
                    style: AppTypography.heading(size: 24),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.mangoTango),
                  ),
                  child: Text(
                    tier.label,
                    style: AppTypography.label(color: AppColors.mangoTango),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                if (tier == UserTier.guest) ...[
                  ElevatedButton(
                    onPressed: () => context.push('/signup'),
                    child: const Text('入居登録する'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.push('/login'),
                    child: const Text('ログイン'),
                  ),
                ] else ...[
                  if (tier != UserTier.resident)
                    ElevatedButton(
                      onPressed: () => context.push('/upgrade'),
                      child: const Text('団地住民になる'),
                    ),
                  if (tier != UserTier.resident) const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) context.go('/welcome');
                    },
                    child: const Text('ログアウト'),
                  ),
                ],
                const Spacer(),
                Text(
                  '品品団地の自室。ここから入居状態を管理できます。',
                  style: AppTypography.body(
                    size: 13,
                    color: AppColors.shuttleGray,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
