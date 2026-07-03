import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/format/format_content_date.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/core/models/user_tier.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/features/content/widgets/tabbed_content_detail_screen.dart';
import 'package:kikikaikai/shared/widgets/access_lock_overlay.dart';
import 'package:kikikaikai/shared/widgets/rich_markdown_body.dart';
import 'package:url_launcher/url_launcher.dart';

class ContentDetailScreen extends ConsumerWidget {
  const ContentDetailScreen({super.key, required this.contentId});

  final String contentId;

  bool _canAccess(Content content, UserTier tier) =>
      tier.canAccess(content.accessLevel);

  bool _isPreviewOnly(Content content, UserTier tier) {
    if (_canAccess(content, tier)) return false;
    return content.type == ContentType.video ||
        content.usesVideoDetailLayout ||
        content.usesAudioDetailLayout;
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  TextStyle get _dateStyle => AppTypography.body(
        size: 14,
        color: AppColors.muted,
        weight: FontWeight.w400,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(contentByIdProvider(contentId));
    final userTier = ref.watch(userTierProvider);
    final downloadIds = ref.watch(downloadIdsProvider).valueOrNull ?? [];
    final isDownloaded = downloadIds.contains(contentId);

    ref.listen(contentByIdProvider(contentId), (previous, next) {
      final content = next.valueOrNull;
      if (content != null && content.type.isTextArticle) {
        ref.read(contentEngagementProvider.notifier).markViewed(content.id);
      }
    });

    return contentAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('読み込みエラー: $e')),
      ),
      data: (content) {
        if (content == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('コンテンツが見つかりません')),
          );
        }

        final canAccess = _canAccess(content, userTier);
        final previewOnly = _isPreviewOnly(content, userTier);

        if (content.type.usesTabbedDetail) {
          return TabbedContentDetailScreen(
            content: content,
            userTier: userTier,
            canAccess: canAccess,
            previewOnly: previewOnly,
            isDownloaded: isDownloaded,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(content.type.label),
            actions: [
              IconButton(
                onPressed: () async {
                  await ref
                      .read(downloadIdsProvider.notifier)
                      .toggleDownload(contentId);
                },
                icon: Icon(
                  isDownloaded
                      ? LucideIcons.circle_check
                      : LucideIcons.download,
                  color: AppColors.onBase,
                ),
                tooltip: isDownloaded ? 'ダウンロード済み' : 'ダウンロード',
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.asset(
                        content.displayThumbnail,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
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
                                style: AppTypography.overline(),
                              ),
                              const Spacer(),
                              Text(
                                formatContentDate(content.publishedAt),
                                style: _dateStyle,
                              ),
                            ],
                          ),
                          if (content.bodyMarkdown != null && canAccess)
                            RichMarkdownBody(data: content.bodyMarkdown!),
                          if (content.type == ContentType.shop &&
                              content.externalUrl != null &&
                              canAccess) ...[
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () =>
                                  _openExternal(content.externalUrl!),
                              child: const Text('購入サイトへ'),
                            ),
                          ],
                        ],
                      ),
                    ),
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
          ),
        );
      },
    );
  }
}
