import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/shared/widgets/author_meta_row.dart';
import 'package:kikikaikai/shared/widgets/content_card_text_block.dart';
import 'package:kikikaikai/core/models/access_level.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/providers/providers.dart';

class ContentCard extends ConsumerWidget {
  const ContentCard({
    super.key,
    required this.content,
    this.width,
  });

  final Content content;
  final double? width;

  static const _radius = 12.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorAsync = ref.watch(authorByIdProvider(content.authorId));
    final savedIds = ref.watch(savedIdsProvider).valueOrNull ?? [];
    final isSaved = savedIds.contains(content.id);
    final userTier = ref.watch(userTierProvider);
    final locked = !userTier.canAccess(content.accessLevel);
    final dateFormat = DateFormat('yyyy.MM.dd');

    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.cardSurface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(_radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/content/${content.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                            size: 28,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 4, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ContentCardTextBlock(
                            title: content.title,
                            subtitle: content.cardSubtitle,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            ref
                                .read(savedIdsProvider.notifier)
                                .toggle(content.id);
                          },
                          icon: Icon(
                            isSaved
                                ? LucideIcons.bookmark_check
                                : LucideIcons.bookmark,
                            size: 20,
                            color: isSaved
                                ? AppColors.mangoTango
                                : AppColors.shuttleGray,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          tooltip: isSaved ? '保存済み' : '保存する',
                        ),
                      ],
                    ),
                    authorAsync.when(
                      loading: () => const SizedBox(height: 24),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (author) {
                        return AuthorMetaRow(
                          author: author,
                          dateLabel: dateFormat.format(content.publishedAt),
                        );
                      },
                    ),
                    if (content.accessLevel != AccessLevel.public) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.mangoTango.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          content.accessLevel.label,
                          style: AppTypography.overline(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
