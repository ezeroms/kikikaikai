import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/features/figure/widgets/figure_contents_scroll.dart';
import 'package:kikikaikai/features/home/home_feed.dart';
import 'package:kikikaikai/shared/widgets/compact_category_content_card.dart';
import 'package:kikikaikai/shared/widgets/content_card.dart';

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
        backgroundColor: AppColors.base,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.base,
        appBar: AppBar(backgroundColor: AppColors.base),
        body: Center(child: Text('読み込みエラー: $e')),
      ),
      data: (figure) {
        if (figure == null) {
          return Scaffold(
            backgroundColor: AppColors.base,
            appBar: AppBar(backgroundColor: AppColors.base),
            body: Center(
              child: Text(
                '人物が見つかりません',
                style: AppTypography.body(color: AppColors.muted),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.base,
          appBar: AppBar(
            backgroundColor: AppColors.base,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          body: contentsAsync.when(
            loading: () => buildFigureContentsArea(
              context,
              figure: figure,
              contentCards: const [
                Center(child: CircularProgressIndicator()),
              ],
            ),
            error: (e, _) => buildFigureContentsArea(
              context,
              figure: figure,
              contentCards: [Center(child: Text('読み込みエラー: $e'))],
            ),
            data: (contents) {
              if (contents.isEmpty) {
                return buildFigureContentsArea(
                  context,
                  figure: figure,
                  contentCards: [
                    Center(
                      child: Text(
                        'コンテンツがありません',
                        style: AppTypography.body(color: AppColors.muted),
                      ),
                    ),
                  ],
                );
              }

              final sorted = HomeFeed.sortByPublishedAtDesc(contents);
              final contentCards =
                  sorted.map(_buildFigureContentCard).toList();

              return buildFigureContentsArea(
                context,
                figure: figure,
                contentCards: contentCards,
              );
            },
          ),
        );
      },
    );
  }
}

Widget _buildFigureContentCard(Content content) {
  if (content.type.usesCompactCategoryCard) {
    return CompactCategoryContentCard(content: content);
  }
  return ContentCard(content: content);
}
