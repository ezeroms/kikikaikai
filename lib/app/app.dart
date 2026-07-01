import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/router.dart';
import 'package:kikikaikai/app/theme/app_theme.dart';
import 'package:kikikaikai/shared/widgets/mini_player_host.dart';

class KikikaikaiApp extends ConsumerWidget {
  const KikikaikaiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: '品品団地',
      theme: AppTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MiniPlayerHost(router: router, child: child);
      },
    );
  }
}
