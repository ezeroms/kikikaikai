import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/content_navigation.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/media/content_card_playback.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/shared/widgets/content_card_text_block.dart';
import 'package:kikikaikai/shared/widgets/figure_meta_row.dart';

/// Vimeo風の縦長おすすめカード（カルーセル用）
class FeaturedContentCard extends ConsumerWidget {
  const FeaturedContentCard({super.key, required this.content});

  final Content content;

  static const _radius = 20.0;

  /// カルーセル全体の高さ（カード固定）
  static const carouselHeight = 420.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final figuresAsync = ref.watch(contentFiguresProvider(content.id));
    final userTier = ref.watch(userTierProvider);
    final canAccess = userTier.canAccess(content.accessLevel);
    final canPlay = ContentCardPlayback.isPlayable(content, userTier);

    return SizedBox(
      height: carouselHeight,
      child: Material(
        color: AppColors.surface,
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
                            size: 36,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ContentCardTextBlock(
                        title: content.title,
                        subtitle: content.description,
                        titleStyle: AppTypography.title(
                          size: 22,
                          weight: FontWeight.w600,
                        ),
                        subtitleStyle: AppTypography.body(
                          size: 14,
                          color: AppColors.muted,
                          weight: FontWeight.w400,
                        ),
                        subtitleMaxLines: 2,
                        textAlign: TextAlign.center,
                        titleSubtitleGap: 8,
                      ),
                      const Spacer(),
                      figuresAsync.when(
                        loading: () => const SizedBox(height: 28),
                        error: (_, _) => const SizedBox.shrink(),
                        data: (figures) {
                          return FigureLinks(
                            figures: figures,
                            centered: true,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
