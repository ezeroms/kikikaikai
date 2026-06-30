import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:url_launcher/url_launcher.dart';

class UpgradeScreen extends ConsumerWidget {
  const UpgradeScreen({super.key});

  static const _subscribeUrl = 'https://pinpin.tokyo/about';

  Future<void> _openBrowser() async {
    final uri = Uri.parse(_subscribeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('団地住民になる')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '団地住民',
              style: AppTypography.heading(size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              'すべてのコンテンツが閲覧できます。',
              style: AppTypography.body(color: AppColors.summerWood),
            ),
            const SizedBox(height: 32),
            _PlanCard(
              floor: '1F',
              price: '550円(税込)/月',
              description: '学生限定の学生寮',
            ),
            const SizedBox(height: 12),
            _PlanCard(
              floor: '2F',
              price: '1,100円(税込)/月',
              description: '一番スタンダードな部屋',
              highlighted: true,
            ),
            const SizedBox(height: 12),
            _PlanCard(
              floor: '3F',
              price: '1,650円(税込)/月',
              description: '少し余裕がある人用の部屋',
            ),
            const Spacer(),
            Text(
              '課金手続きはブラウザで行います',
              style: AppTypography.label(size: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _openBrowser,
              child: const Text('ブラウザで手続きする'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).upgradeToResident();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('団地住民になりました（ダミー）'),
                    ),
                  );
                  context.pop();
                }
              },
              child: const Text('手続き完了（ダミー）'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.floor,
    required this.price,
    required this.description,
    this.highlighted = false,
  });

  final String floor;
  final String price;
  final String description;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.darkSurface : Colors.transparent,
        border: Border.all(
          color: highlighted ? AppColors.mangoTango : AppColors.riverRoad,
          width: highlighted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(floor, style: AppTypography.label(color: AppColors.mangoTango)),
          const SizedBox(height: 4),
          Text(price, style: AppTypography.heading(size: 18)),
          const SizedBox(height: 4),
          Text(
            description,
            style: AppTypography.body(size: 13, color: AppColors.shuttleGray),
          ),
        ],
      ),
    );
  }
}
