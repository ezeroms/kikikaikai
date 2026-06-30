import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/core/models/user_tier.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/features/content/widgets/radio_player_widget.dart';
import 'package:kikikaikai/features/content/widgets/tv_player_widget.dart';
import 'package:kikikaikai/shared/widgets/access_lock_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

class ContentDetailScreen extends ConsumerWidget {
  const ContentDetailScreen({super.key, required this.contentId});

  final String contentId;

  bool _canAccess(Content content, UserTier tier) =>
      tier.canAccess(content.accessLevel);

  bool _isPreviewOnly(Content content, UserTier tier) {
    if (_canAccess(content, tier)) return false;
    return content.type == ContentType.video ||
        content.type == ContentType.audio;
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(contentByIdProvider(contentId));
    final userTier = ref.watch(userTierProvider);
    final savedIds = ref.watch(savedIdsProvider).valueOrNull ?? [];
    final isSaved = savedIds.contains(contentId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('詳細'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(savedIdsProvider.notifier).toggle(contentId);
            },
            icon: Icon(
              isSaved ? LucideIcons.bookmark_check : LucideIcons.bookmark,
              color: isSaved ? AppColors.mangoTango : AppColors.summerWood,
            ),
            tooltip: isSaved ? '保存済み' : '保存する',
          ),
        ],
      ),
      body: contentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('読み込みエラー: $e')),
        data: (content) {
          if (content == null) {
            return const Center(child: Text('コンテンツが見つかりません'));
          }
          final canAccess = _canAccess(content, userTier);
          final previewOnly = _isPreviewOnly(content, userTier);
          final showPlayer = content.mediaUrl != null && (canAccess || previewOnly);
          final authorAsync = ref.watch(authorByIdProvider(content.authorId));

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          style: AppTypography.label(
                            color: AppColors.mangoTango,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      content.title,
                      style: AppTypography.heading(size: 22),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('yyyy年M月d日').format(content.publishedAt),
                      style: AppTypography.label(size: 12),
                    ),
                    authorAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (author) {
                        if (author == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '執筆: ${author.name}',
                            style: AppTypography.body(
                              size: 14,
                              color: AppColors.summerWood,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    if (showPlayer && content.type == ContentType.video)
                      TvPlayerWidget(
                        key: ValueKey(content.id),
                        content: content,
                        previewLimit: previewOnly
                            ? const Duration(seconds: 30)
                            : null,
                      ),
                    if (showPlayer && content.type == ContentType.audio)
                      RadioPlayerWidget(
                        key: ValueKey(content.id),
                        content: content,
                        previewLimit: previewOnly
                            ? const Duration(seconds: 30)
                            : null,
                      ),
                    if (content.bodyMarkdown != null && canAccess)
                      MarkdownBody(
                        data: content.bodyMarkdown!,
                        styleSheet: MarkdownStyleSheet(
                          p: AppTypography.body(size: 15),
                          h1: AppTypography.heading(size: 20),
                          h2: AppTypography.heading(size: 18),
                          blockquote: AppTypography.body(
                            color: AppColors.summerWood,
                          ),
                        ),
                      ),
                    if (content.type == ContentType.shop &&
                        content.externalUrl != null &&
                        canAccess) ...[
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _openExternal(content.externalUrl!),
                        child: const Text('購入サイトへ'),
                      ),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              if (!canAccess && !previewOnly)
                AccessLockOverlay(
                  accessLevel: content.accessLevel,
                  userTier: userTier,
                ),
            ],
          );
        },
      ),
    );
  }
}
