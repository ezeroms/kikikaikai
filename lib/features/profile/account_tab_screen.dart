import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/features/auth/widgets/login_form.dart';
import 'package:kikikaikai/features/profile/profile_screen.dart';

/// ボトムタブ用：未ログイン時はログイン、ログイン済みはマイページ
class AccountTabScreen extends ConsumerWidget {
  const AccountTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authProvider);

    return authAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('マイページ')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('マイページ')),
        body: Center(child: Text('エラー: $e')),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('ログイン')),
            body: const LoginForm(),
          );
        }
        return const ProfileScreen();
      },
    );
  }
}
