import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/shared/widgets/content_card.dart';
import 'package:kikikaikai/shared/widgets/mini_player_bar.dart';

/// マイページから遷移するダウンロード済みコンテンツ一覧
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadsAsync = ref.watch(downloadedContentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ダウンロードしたコンテンツ')),
      body: downloadsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('読み込みエラー: $error')),
        data: (contents) {
          if (contents.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ダウンロードしたコンテンツはありません',
                      style: AppTypography.heading(size: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'コンテンツ詳細画面からダウンロードできます',
                      style: AppTypography.body(
                        color: AppColors.muted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              32 + miniPlayerScrollPadding(context),
            ),
            itemCount: contents.length,
            separatorBuilder: (_, _) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              return ContentCard(content: contents[index]);
            },
          );
        },
      ),
    );
  }
}
