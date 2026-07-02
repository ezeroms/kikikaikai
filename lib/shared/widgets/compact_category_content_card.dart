import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/content_navigation.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/core/format/format_content_date.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/media/content_card_playback.dart';
import 'package:kikikaikai/core/media/content_playback_progress_resolver.dart';
import 'package:kikikaikai/core/media/kikikaikai_media_handler.dart';
import 'package:kikikaikai/core/media/media_playback.dart';
import 'package:kikikaikai/core/models/content_engagement.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/shared/widgets/audio_playback_indicator.dart';
import 'package:kikikaikai/shared/widgets/content_card_play_button.dart';
import 'package:kikikaikai/shared/widgets/figure_meta_row.dart';

/// カテゴリタブ向けコンパクトカード（テキスト・音声）
class CompactCategoryContentCard extends ConsumerWidget {
  const CompactCategoryContentCard({
    super.key,
    required this.content,
  });

  final Content content;

  static const _radius = 12.0;
  static const _thumbWidth = 72.0;
  static const _thumbRadius = 8.0;
  static const _figureVerticalSpacing = 12.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final figuresAsync = ref.watch(contentFiguresProvider(content.id));
    final userTier = ref.watch(userTierProvider);
    final engagement =
        ref.watch(contentEngagementProvider).valueOrNull ?? ContentEngagementState.empty;
    final canAccess = userTier.canAccess(content.accessLevel);
    final canPlay = ContentCardPlayback.isPlayable(content, userTier);
    final isAudio = content.type.isAudioPlayback;
    final isViewed = engagement.isViewed(content.id);
    final savedPlayback = isAudio ? engagement.playbackFor(content.id) : null;
    final isCompleted = isAudio ? savedPlayback?.completed == true : isViewed;
    final showsPlayButton =
        ContentCardPlayback.showsCardPlayButton(content, userTier);
    final dateLabel = formatContentDate(content.publishedAt);
    final handler = MediaPlayback.handler;
    final fallbackDurationMs = content.playbackDuration?.inMilliseconds;

    return Material(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(_radius),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            onTap: () => ContentNavigation.openDetail(context, content.id),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ThumbnailTitleRow(
                    content: content,
                    canAccess: canAccess,
                    canPlay: canPlay,
                    isAudio: isAudio,
                    isCompleted: isCompleted,
                  ),
                  if (content.cardSubtitle != null &&
                      content.cardSubtitle!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      content.cardSubtitle!,
                      style: AppTypography.body(
                        size: 13,
                        color: AppColors.muted,
                        weight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: _figureVerticalSpacing),
                  Padding(
                    padding: EdgeInsets.only(
                      right: showsPlayButton ? 44 : 0,
                    ),
                    child: figuresAsync.when(
                      loading: () => const SizedBox(height: 20),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (figures) => FigureMetaRow(
                        figures: figures,
                        dateLabel: dateLabel,
                        avatarRadius: 10,
                        metaFontSize: 12,
                        nameStyle: AppTypography.titleSmall(size: 12)
                            .copyWith(fontWeight: FontWeight.w400),
                        accessLabel:
                            isAudio ? content.accessLevel.cardBadgeLabel : null,
                        compact: true,
                        showDate: false,
                      ),
                    ),
                  ),
                  if (!isAudio)
                    Padding(
                      padding: EdgeInsets.only(
                        top: _figureVerticalSpacing,
                        right: showsPlayButton ? 44 : 0,
                      ),
                      child: _CompactTextMetaLine(
                        dateLabel: dateLabel,
                        accessLabel: content.accessLevel.cardBadgeLabel,
                      ),
                    ),
                  if (isAudio)
                    Padding(
                      padding: EdgeInsets.only(
                        top: _figureVerticalSpacing,
                        right: showsPlayButton ? 44 : 0,
                      ),
                      child: _AudioPlaybackIndicatorSection(
                        content: content,
                        handler: handler,
                        savedPlayback: savedPlayback,
                        dateLabel: dateLabel,
                        fallbackDurationMs: fallbackDurationMs,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (showsPlayButton)
            Positioned(
              right: 16,
              bottom: 16,
              child: ContentCardPlayButton(
                content: content,
                compact: true,
              ),
            ),
        ],
      ),
    );
  }
}

class _ThumbnailTitleRow extends StatelessWidget {
  const _ThumbnailTitleRow({
    required this.content,
    required this.canAccess,
    required this.canPlay,
    required this.isAudio,
    required this.isCompleted,
  });

  final Content content;
  final bool canAccess;
  final bool canPlay;
  final bool isAudio;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(CompactCategoryContentCard._thumbRadius),
          child: SizedBox(
            width: CompactCategoryContentCard._thumbWidth,
            child: AspectRatio(
              aspectRatio: 1,
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
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  content.title,
                  style: AppTypography.titleSmall(size: 15),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isCompleted && !isAudio) ...[
                const SizedBox(width: 8),
                const Icon(
                  LucideIcons.circle_check,
                  size: 18,
                  color: AppColors.muted,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactTextMetaLine extends StatelessWidget {
  const _CompactTextMetaLine({
    required this.dateLabel,
    this.accessLabel,
  });

  final String dateLabel;
  final String? accessLabel;

  @override
  Widget build(BuildContext context) {
    final metaStyle = AppTypography.body(
      size: 12,
      color: AppColors.muted,
      weight: FontWeight.w400,
    );

    return Row(
      children: [
        Text(dateLabel, style: metaStyle),
        if (accessLabel != null && accessLabel!.isNotEmpty) ...[
          const SizedBox(width: 8),
          FigureMetaAccessLabel(text: accessLabel!),
        ],
      ],
    );
  }
}

class _AudioPlaybackIndicatorSection extends StatelessWidget {
  const _AudioPlaybackIndicatorSection({
    required this.content,
    required this.handler,
    required this.savedPlayback,
    required this.dateLabel,
    required this.fallbackDurationMs,
  });

  final Content content;
  final KikikaikaiMediaHandler? handler;
  final ContentPlaybackProgress? savedPlayback;
  final String dateLabel;
  final int? fallbackDurationMs;

  @override
  Widget build(BuildContext context) {
    final mediaHandler = handler;

    if (mediaHandler == null) {
      return AudioPlaybackIndicator(
        dateLabel: dateLabel,
        progress: ContentPlaybackProgressResolver.resolveDisplayProgress(
          handler: null,
          contentId: content.id,
          savedProgress: savedPlayback,
          playbackState: null,
          content: content,
        ),
        totalDurationMs: fallbackDurationMs,
      );
    }

    return StreamBuilder<PlaybackState>(
      stream: mediaHandler.playbackState,
      builder: (context, snapshot) {
        final isCurrent = mediaHandler.currentContent?.id == content.id;
        final isPlaying = isCurrent && (snapshot.data?.playing ?? false);

        return AudioPlaybackIndicator(
          dateLabel: dateLabel,
          progress: ContentPlaybackProgressResolver.resolveDisplayProgress(
            handler: mediaHandler,
            contentId: content.id,
            savedProgress: savedPlayback,
            playbackState: snapshot.data,
            content: content,
          ),
          totalDurationMs: fallbackDurationMs,
          isPlaying: isPlaying,
        );
      },
    );
  }
}
