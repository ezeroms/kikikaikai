import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/features/home/home_feed.dart';
import 'package:kikikaikai/features/home/home_tab.dart';
import 'package:kikikaikai/features/home/widgets/category_profile_header.dart';
import 'package:kikikaikai/features/home/widgets/home_tab_scroll.dart';
import 'package:kikikaikai/shared/widgets/compact_category_content_card.dart';
import 'package:kikikaikai/shared/widgets/content_card.dart';

/// 鑑賞画面のカテゴリタブ（奇奇怪怪・回覧板など）
class HomeCategoryTab extends ConsumerWidget {
  const HomeCategoryTab({
    super.key,
    required this.tab,
  });

  final HomeTab tab;

  ContentType get contentType => tab.contentType!;

  CategoryProfileScrollHeader get profileHeader => CategoryProfileScrollHeader(
        title: tab.label,
        description: tab.profileDescription,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentsAsync = ref.watch(contentsByTypeProvider(contentType));
    final imageAsset = tab.profileHeroAsset!;

    return contentsAsync.when(
      loading: () => buildHomeCategoryTabScroll(
        context,
        imageAsset: imageAsset,
        header: profileHeader,
        contentCards: const [Center(child: CircularProgressIndicator())],
      ),
      error: (error, _) => buildHomeCategoryTabScroll(
        context,
        imageAsset: imageAsset,
        header: profileHeader,
        contentCards: [Center(child: Text('読み込みエラー: $error'))],
      ),
      data: (contents) {
        if (contents.isEmpty) {
          return buildHomeCategoryTabScroll(
            context,
            imageAsset: imageAsset,
            header: profileHeader,
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

        final sortedContents = HomeFeed.sortByPublishedAtDesc(contents);
        final contentCards = sortedContents
            .map((content) => _buildCategoryContentCard(content))
            .toList();

        return buildHomeCategoryTabScroll(
          context,
          imageAsset: imageAsset,
          header: profileHeader,
          contentCards: contentCards,
        );
      },
    );
  }
}

Widget _buildCategoryContentCard(Content content) {
  if (content.type.usesCompactCategoryCard) {
    return CompactCategoryContentCard(content: content);
  }
  return ContentCard(content: content);
}
