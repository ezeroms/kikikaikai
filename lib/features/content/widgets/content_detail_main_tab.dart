import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/format/format_content_date.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/media/media_timestamp_seek.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/features/content/widgets/content_detail_nested_tab_scroll.dart';
import 'package:kikikaikai/shared/widgets/figure_meta_row.dart';
import 'package:kikikaikai/shared/widgets/rich_markdown_body.dart';
import 'package:kikikaikai/shared/widgets/timestamp_link_text.dart';

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

  Duration? _previewLimit() =>
      previewOnly ? content.previewDuration : null;

  void _seekToTimestamp(Duration position) {
    MediaTimestampSeek.seek(
      content,
      position,
      previewLimit: _previewLimit(),
    );
  }

  ValueChanged<Duration>? get _onSeekTimestamp =>
      content.type.supportsMediaTimestampLinks ? _seekToTimestamp : null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final figuresAsync = ref.watch(contentFiguresProvider(content.id));

    if (content.usesVideoDetailLayout) {
      return _VideoDetailMainTab(
        content: content,
        canAccess: canAccess,
        previewLimit: _previewLimit(),
      );
    }

    if (content.type.isTextArticle) {
      return _TextArticleDetailMainTab(
        content: content,
        canAccess: canAccess,
      );
    }

    if (content.usesAudioDetailLayout) {
      return _KikikaikaiDetailMainTab(
        content: content,
        canAccess: canAccess,
        onSeekTimestamp: _onSeekTimestamp,
      );
    }

    return Builder(
      builder: (context) => buildContentDetailNestedScroll(
        context,
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
            if (content.bodyMarkdown != null && canAccess) ...[
              const SizedBox(height: 24),
              RichMarkdownBody(
                data: content.bodyMarkdown!,
                onSeekTimestamp: _onSeekTimestamp,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _KikikaikaiDetailMainTab extends StatelessWidget {
  const _KikikaikaiDetailMainTab({
    required this.content,
    required this.canAccess,
    this.onSeekTimestamp,
  });

  final Content content;
  final bool canAccess;
  final ValueChanged<Duration>? onSeekTimestamp;

  @override
  Widget build(BuildContext context) {
    if (content.bodyMarkdown == null || !canAccess) {
      return Builder(
        builder: (context) => buildContentDetailNestedScrollSlivers(
          context,
          slivers: const [SliverToBoxAdapter(child: SizedBox.shrink())],
        ),
      );
    }

    return Builder(
      builder: (context) => buildContentDetailNestedScroll(
        context,
        child: RichMarkdownBody(
          data: content.bodyMarkdown!,
          onSeekTimestamp: onSeekTimestamp,
        ),
      ),
    );
  }
}

class _TextArticleDetailMainTab extends StatelessWidget {
  const _TextArticleDetailMainTab({
    required this.content,
    required this.canAccess,
  });

  final Content content;
  final bool canAccess;

  @override
  Widget build(BuildContext context) {
    if (content.bodyMarkdown == null || !canAccess) {
      return Builder(
        builder: (context) => buildContentDetailNestedScrollSlivers(
          context,
          slivers: const [SliverToBoxAdapter(child: SizedBox.shrink())],
        ),
      );
    }

    return Builder(
      builder: (context) => buildContentDetailNestedScroll(
        context,
        child: RichMarkdownBody(data: content.bodyMarkdown!),
      ),
    );
  }
}

class _VideoDetailMainTab extends StatelessWidget {
  const _VideoDetailMainTab({
    required this.content,
    required this.canAccess,
    this.previewLimit,
  });

  final Content content;
  final bool canAccess;
  final Duration? previewLimit;

  @override
  Widget build(BuildContext context) {
    if (content.description.trim().isEmpty) {
      return Builder(
        builder: (context) => buildContentDetailNestedScrollSlivers(
          context,
          slivers: const [SliverToBoxAdapter(child: SizedBox.shrink())],
        ),
      );
    }

    final bodyStyle = AppTypography.body(
      size: 15,
      color: AppColors.muted,
      weight: FontWeight.w400,
    );

    return Builder(
      builder: (context) => buildContentDetailNestedScroll(
        context,
        child: TimestampLinkText(
          text: content.description,
          style: bodyStyle,
          content: content,
          previewLimit: previewLimit,
        ),
      ),
    );
  }
}
