import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/login'),
                    child: const Text('ログイン'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/browse'),
                  child: const Text('とりあえず見学'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
