import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/models/access_level.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/shared/widgets/paper_tape_heading.dart';

class ContentListScreen extends ConsumerWidget {
  const ContentListScreen({super.key, required this.type});

  final ContentType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentsAsync = ref.watch(contentsByTypeProvider(type));
    final userTier = ref.watch(userTierProvider);
    final dateFormat = DateFormat('yyyy.MM.dd');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(type.iconAsset, width: 28, height: 28),
            const SizedBox(width: 8),
            Text(type.label),
          ],
        ),
      ),
      body: contentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('読み込みエラー: $e')),
        data: (contents) {
          if (contents.isEmpty) {
            return Center(
              child: Text(
                'コンテンツがありません',
                style: AppTypography.body(color: AppColors.shuttleGray),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contents.length,
            itemBuilder: (context, index) {
              final content = contents[index];
              final locked = !userTier.canAccess(content.accessLevel);
              return InkWell(
                onTap: () => context.push('/content/${content.id}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PaperTapeHeading(
                      title: content.title,
                      date: dateFormat.format(content.publishedAt),
                      isOdd: index.isOdd,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              content.description,
                              style: AppTypography.body(
                                size: 13,
                                color: AppColors.shuttleGray,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (locked)
                            const Icon(
                              Icons.lock_outline,
                              size: 16,
                              color: AppColors.mangoTango,
                            ),
                          if (content.accessLevel != AccessLevel.public)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.riverRoad,
                                ),
                              ),
                              child: Text(
                                content.accessLevel.label,
                                style: AppTypography.label(size: 10),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
