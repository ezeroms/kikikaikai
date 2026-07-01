import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/shared/widgets/content_card_text_block.dart';

/// Vimeo風の縦長おすすめカード（カルーセル用）
class FeaturedContentCard extends ConsumerWidget {
  const FeaturedContentCard({super.key, required this.content});

  final Content content;

  static const _radius = 20.0;

  bool get _hasPlayableMedia =>
      content.mediaUrl != null &&
      (content.type == ContentType.video || content.type.isAudioPlayback);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorAsync = ref.watch(authorByIdProvider(content.authorId));
    final savedIds = ref.watch(savedIdsProvider).valueOrNull ?? [];
    final isSaved = savedIds.contains(content.id);
    final userTier = ref.watch(userTierProvider);
    final locked = !userTier.canAccess(content.accessLevel);

    return Material(
      color: AppColors.cardSurface,
      borderRadius: BorderRadius.circular(_radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/content/${content.id}'),
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
                  if (locked)
                    ColoredBox(
                      color: Colors.black.withValues(alpha: 0.45),
                      child: const Center(
                        child: Icon(
                          LucideIcons.lock,
                          color: AppColors.summerWood,
                          size: 36,
                        ),
                      ),
                    ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () {
                          ref
                              .read(savedIdsProvider.notifier)
                              .toggle(content.id);
                        },
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            isSaved
                                ? LucideIcons.bookmark_check
                                : LucideIcons.bookmark,
                            size: 20,
                            color: isSaved
                                ? AppColors.mangoTango
                                : AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  children: [
                    ContentCardTextBlock(
                      title: content.title,
                      subtitle: content.description,
                      titleStyle: AppTypography.title(
                        size: 24,
                        weight: FontWeight.w600,
                      ),
                      subtitleStyle: AppTypography.body(
                        size: 16,
                        color: AppColors.shuttleGray,
                        weight: FontWeight.w400,
                      ),
                      subtitleMaxLines: 3,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    authorAsync.when(
                      loading: () => const SizedBox(height: 28),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (author) {
                        if (author == null) {
                          return const SizedBox.shrink();
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundImage:
                                  AssetImage(author.avatarAsset),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                author.name,
                                style: AppTypography.label(
                                  size: 13,
                                  weight: FontWeight.w400,
                                  color: AppColors.shuttleGray,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const Spacer(),
                    if (_hasPlayableMedia && !locked)
                      Material(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 12,
                          ),
                          child: Icon(
                            content.type == ContentType.video
                                ? LucideIcons.play
                                : LucideIcons.headphones,
                            color: AppColors.white,
                            size: 22,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
