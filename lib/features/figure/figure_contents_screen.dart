import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/shared/widgets/content_card.dart';
import 'package:kikikaikai/shared/widgets/mini_player_bar.dart';

/// Figure にタグ付けされたコンテンツ一覧
class FigureContentsScreen extends ConsumerWidget {
  const FigureContentsScreen({super.key, required this.figureId});

  final String figureId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final figureAsync = ref.watch(figureByIdProvider(figureId));
    final contentsAsync = ref.watch(contentsByFigureProvider(figureId));

    return figureAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('読み込みエラー: $e')),
      ),
      data: (figure) {
        if (figure == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text(
                '人物が見つかりません',
                style: AppTypography.body(color: AppColors.muted),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('${figure.name} に関係するコンテンツ'),
          ),
          body: contentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('読み込みエラー: $e')),
            data: (contents) {
              if (contents.isEmpty) {
                return Center(
                  child: Text(
                    'コンテンツがありません',
                    style: AppTypography.body(color: AppColors.muted),
                  ),
                );
              }

              final sorted = [...contents]
                ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

              return ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  32 + miniPlayerScrollPadding(context),
                ),
                itemCount: sorted.length,
                separatorBuilder: (_, _) => const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  return ContentCard(content: sorted[index]);
                },
              );
            },
          ),
        );
      },
    );
  }
}
