import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/format/format_content_date.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/features/content/widgets/tv_player_widget.dart';
import 'package:kikikaikai/shared/widgets/figure_meta_row.dart';
import 'package:kikikaikai/shared/widgets/rich_markdown_body.dart';

class ContentDetailMainTab extends ConsumerWidget {
  const ContentDetailMainTab({
    super.key,
    required this.content,
    required this.canAccess,
    this.previewOnly = false,
  });

  final Content content;
  final bool canAccess;
  final bool previewOnly;

  TextStyle get _figureNameStyle => AppTypography.titleSmall(size: 14).copyWith(
        fontWeight: FontWeight.w400,
      );

  bool get _showVideoPlayer =>
      content.type == ContentType.video &&
      content.mediaUrl != null &&
      (canAccess || previewOnly);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final figuresAsync = ref.watch(contentFiguresProvider(content.id));

    if (content.type == ContentType.video) {
      return _VideoDetailMainTab(
        content: content,
        canAccess: canAccess,
        previewOnly: previewOnly,
        showVideoPlayer: _showVideoPlayer,
        figureNameStyle: _figureNameStyle,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!content.type.isAudioPlayback) ...[
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  content.displayThumbnail,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Image.asset(
                  content.type.iconAsset,
                  width: 32,
                  height: 32,
                ),
                const SizedBox(width: 8),
                Text(
                  content.type.label,
                  style: AppTypography.overline(),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          figuresAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (figures) => FigureMetaRow(
              figures: figures,
              dateLabel: '',
              showDate: false,
              compact: true,
              avatarRadius: 14,
              metaFontSize: 14,
              nameStyle: _figureNameStyle,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            formatContentDate(content.publishedAt),
            style: AppTypography.body(
              size: 14,
              color: AppColors.muted,
              weight: FontWeight.w400,
            ),
          ),
          if (content.cardSubtitle != null &&
              content.cardSubtitle!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              content.cardSubtitle!,
              style: AppTypography.body(
                size: 15,
                color: AppColors.muted,
                weight: FontWeight.w400,
              ),
            ),
          ],
          if (content.description.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              content.description,
              style: AppTypography.body(size: 15),
            ),
          ],
          if (content.bodyMarkdown != null && canAccess) ...[
            const SizedBox(height: 24),
            RichMarkdownBody(data: content.bodyMarkdown!),
          ],
        ],
      ),
    );
  }
}

class _VideoDetailMainTab extends ConsumerWidget {
  const _VideoDetailMainTab({
    required this.content,
    required this.canAccess,
    required this.previewOnly,
    required this.showVideoPlayer,
    required this.figureNameStyle,
  });

  final Content content;
  final bool canAccess;
  final bool previewOnly;
  final bool showVideoPlayer;
  final TextStyle figureNameStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final figuresAsync = ref.watch(contentFiguresProvider(content.id));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showVideoPlayer)
            TvPlayerWidget(
              key: ValueKey(content.id),
              content: content,
              previewLimit: previewOnly ? const Duration(seconds: 30) : null,
              edgeToEdge: true,
            )
          else
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                content.displayThumbnail,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  content.title,
                  style: AppTypography.titleSmall(size: 20),
                ),
                const SizedBox(height: 16),
                figuresAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (figures) => FigureMetaRow(
                    figures: figures,
                    dateLabel: '',
                    showDate: false,
                    compact: true,
                    avatarRadius: 14,
                    metaFontSize: 14,
                    nameStyle: figureNameStyle,
                  ),
                ),
                if (content.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    content.description,
                    style: AppTypography.body(
                      size: 15,
                      color: AppColors.muted,
                      weight: FontWeight.w400,
                    ),
                  ),
                ],
                if (content.bodyMarkdown != null && canAccess) ...[
                  const SizedBox(height: 24),
                  RichMarkdownBody(data: content.bodyMarkdown!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
