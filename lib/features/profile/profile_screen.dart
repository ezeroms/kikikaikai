import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
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
        title: const Text('マイページ'),
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
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: AssetImage(
                      user?.avatarAsset ??
                          'assets/branding/eye_catch/mypage.png',
                    ),
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
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Text(
                    tier.label,
                    style: AppTypography.label(color: AppColors.primary),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                if (user != null) ...[
                  Material(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      leading: const Icon(
                        LucideIcons.download,
                        color: AppColors.secondary,
                      ),
                      title: Text(
                        'ダウンロードしたコンテンツ',
                        style: AppTypography.body(size: 15),
                      ),
                      trailing: const Icon(
                        LucideIcons.chevron_right,
                        color: AppColors.muted,
                        size: 20,
                      ),
                      onTap: () => context.push('/downloads'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
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
                    },
                    child: const Text('ログアウト'),
                  ),
                ],
                const Spacer(),
                Text(
                  '品品団地のマイページ。ここから入居状態を管理できます。',
                  style: AppTypography.body(
                    size: 13,
                    color: AppColors.muted,
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
