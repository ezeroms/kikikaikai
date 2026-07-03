import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/format/format_content_date.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/shared/widgets/figure_meta_row.dart';

/// 回覧板・玉稿詳細のスクロール可能ヘッダー（タイトル・Figure・公開日）
class TextArticleDetailHeader extends ConsumerWidget {
  const TextArticleDetailHeader({super.key, required this.content});

  final Content content;

  TextStyle get _figureNameStyle => AppTypography.titleSmall(size: 14).copyWith(
        fontWeight: FontWeight.w400,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final figuresAsync = ref.watch(contentFiguresProvider(content.id));
    final dateLabel = formatContentDate(content.publishedAt);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            content.title,
            style: AppTypography.title(
              size: 26,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          figuresAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (figures) => FigureMetaRow(
              figures: figures,
              dateLabel: dateLabel,
              showDate: true,
              compact: true,
              avatarRadius: 14,
              metaFontSize: 14,
              nameStyle: _figureNameStyle,
            ),
          ),
        ],
      ),
    );
  }
}
