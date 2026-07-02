import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/content_navigation.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/core/format/format_content_date.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/shared/widgets/figure_meta_row.dart';
import 'package:kikikaikai/shared/widgets/content_card_text_block.dart';
import 'package:kikikaikai/core/media/content_card_playback.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/figure.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/shared/widgets/content_card_play_button.dart';

class ContentCard extends ConsumerWidget {
  const ContentCard({
    super.key,
    required this.content,
    this.width,
    this.height,
    this.showPlayButton = true,
  });

  final Content content;
  final double? width;
  final double? height;
  final bool showPlayButton;

  static const _radius = 12.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final figuresAsync = ref.watch(contentFiguresProvider(content.id));
    final userTier = ref.watch(userTierProvider);
    final canAccess = userTier.canAccess(content.accessLevel);
    final canPlay = ContentCardPlayback.isPlayable(content, userTier);
    final showsPlayButton = showPlayButton &&
        ContentCardPlayback.showsCardPlayButton(content, userTier);
    final details = _ContentCardDetails(
      content: content,
      figuresAsync: figuresAsync,
      showsPlayButton: showsPlayButton,
      expandText: height != null,
    );

    final card = Material(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(_radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => ContentNavigation.openDetail(context, content.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    content.displayThumbnail,
                    fit: BoxFit.cover,
                  ),
                  if (!canAccess && !canPlay)
                    ColoredBox(
                      color: Colors.black.withValues(alpha: 0.45),
                      child: const Center(
                        child: Icon(
                          LucideIcons.lock,
                          color: AppColors.secondary,
                          size: 28,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (height != null)
              Expanded(child: details)
            else
              details,
          ],
        ),
      ),
    );

    if (width != null || height != null) {
      return SizedBox(width: width, height: height, child: card);
    }
    return card;
  }
}

class _ContentCardDetails extends StatelessWidget {
  const _ContentCardDetails({
    required this.content,
    required this.figuresAsync,
    required this.showsPlayButton,
    required this.expandText,
  });

  final Content content;
  final AsyncValue<List<Figure>> figuresAsync;
  final bool showsPlayButton;
  final bool expandText;

  @override
  Widget build(BuildContext context) {
    final textBlock = ContentCardTextBlock(
      title: content.title,
      subtitle: content.cardSubtitle,
    );

    final textRow = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: textBlock),
        if (showsPlayButton)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: ContentCardPlayButton(
              content: content,
              compact: true,
            ),
          ),
      ],
    );

    final figures = figuresAsync.when(
      loading: () => const SizedBox(height: 22),
      error: (_, _) => const SizedBox.shrink(),
      data: (figures) {
        return FigureMetaRow(
          figures: figures,
          dateLabel: formatContentDate(content.publishedAt),
          metaFontSize: 14,
          nameStyle: AppTypography.titleSmall(size: 14).copyWith(
            fontWeight: FontWeight.w400,
          ),
          accessLabel: content.accessLevel.cardBadgeLabel,
          compact: true,
        );
      },
    );

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (expandText) Expanded(child: textRow) else textRow,
          const SizedBox(height: 12),
          figures,
        ],
      ),
    );
  }
}
