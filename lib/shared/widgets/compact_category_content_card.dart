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
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/core/models/figure.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/shared/widgets/audio_playback_indicator.dart';
import 'package:kikikaikai/shared/widgets/content_card_play_button.dart';
import 'package:kikikaikai/shared/widgets/figure_meta_row.dart';
import 'package:kikikaikai/shared/widgets/glass_card.dart';

/// カテゴリタブ向けコンパクトカード（テキスト・音声）
class CompactCategoryContentCard extends ConsumerWidget {
  const CompactCategoryContentCard({
    super.key,
    required this.content,
  });

  final Content content;

  static const _radius = 12.0;
  static const _contentPadding = 16.0;
  static const _thumbWidth = 72.0;
  static const _thumbRadius = 8.0;
  static const _landscapeThumbAspectRatio = 16 / 9;
  static const _titleTopSpacingAfterThumb = 12.0;
  static const _figureVerticalSpacing = 12.0;
  static const _subtitleTopSpacing = 12.0;

  static TextStyle get _titleStyle =>
      AppTypography.titleSmall(size: 15).copyWith(height: 1.48);

  static bool _usesStackedMediaLayout(Content content) {
    return content.type == ContentType.video ||
        content.type == ContentType.audio;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final figuresAsync = ref.watch(contentFiguresProvider(content.id));
    final userTier = ref.watch(userTierProvider);
    final engagement =
        ref.watch(contentEngagementProvider).valueOrNull ?? ContentEngagementState.empty;
    final canAccess = userTier.canAccess(content.accessLevel);
    final canPlay = ContentCardPlayback.isPlayable(content, userTier);
    final isAudio = content.usesAudioDetailLayout;
    final usesStackedMediaLayout = _usesStackedMediaLayout(content);
    final savedPlayback = isAudio ? engagement.playbackFor(content.id) : null;
    final showsPlayButton =
        ContentCardPlayback.showsCardPlayButton(content, userTier);
    final dateLabel = formatContentDate(content.publishedAt);
    final handler = MediaPlayback.handler;
    final fallbackDurationMs = content.playbackDuration?.inMilliseconds;
    final cardSubtitle = _compactCardSubtitle(content);

    return GlassCardSurface(
      borderRadius: _radius,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              onTap: () => ContentNavigation.openDetail(context, content.id),
              child: usesStackedMediaLayout
                  ? _StackedMediaCardBody(
                      content: content,
                      canAccess: canAccess,
                      canPlay: canPlay,
                      cardSubtitle: cardSubtitle,
                      figuresAsync: figuresAsync,
                      dateLabel: dateLabel,
                      isAudio: isAudio,
                      showsPlayButton: showsPlayButton,
                      handler: handler,
                      savedPlayback: savedPlayback,
                      fallbackDurationMs: fallbackDurationMs,
                    )
                  : _HorizontalCardBody(
                      content: content,
                      canAccess: canAccess,
                      canPlay: canPlay,
                      cardSubtitle: cardSubtitle,
                      figuresAsync: figuresAsync,
                      dateLabel: dateLabel,
                      isAudio: isAudio,
                      showsPlayButton: showsPlayButton,
                      handler: handler,
                      savedPlayback: savedPlayback,
                      fallbackDurationMs: fallbackDurationMs,
                    ),
            ),
            if (showsPlayButton)
              Positioned(
                right: _contentPadding,
                bottom: _contentPadding,
                child: ContentCardPlayButton(
                  content: content,
                  compact: true,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalCardBody extends StatelessWidget {
  const _HorizontalCardBody({
    required this.content,
    required this.canAccess,
    required this.canPlay,
    required this.cardSubtitle,
    required this.figuresAsync,
    required this.dateLabel,
    required this.isAudio,
    required this.showsPlayButton,
    required this.handler,
    required this.savedPlayback,
    required this.fallbackDurationMs,
  });

  final Content content;
  final bool canAccess;
  final bool canPlay;
  final String? cardSubtitle;
  final AsyncValue<List<Figure>> figuresAsync;
  final String dateLabel;
  final bool isAudio;
  final bool showsPlayButton;
  final KikikaikaiMediaHandler? handler;
  final ContentPlaybackProgress? savedPlayback;
  final int? fallbackDurationMs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(CompactCategoryContentCard._contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HorizontalThumbnailTitleRow(
            content: content,
            canAccess: canAccess,
            canPlay: canPlay,
          ),
          ..._CardTextSections.build(
            content: content,
            cardSubtitle: cardSubtitle,
            figuresAsync: figuresAsync,
            dateLabel: dateLabel,
            isAudio: isAudio,
            showsPlayButton: showsPlayButton,
            handler: handler,
            savedPlayback: savedPlayback,
            fallbackDurationMs: fallbackDurationMs,
          ),
        ],
      ),
    );
  }
}

class _StackedMediaCardBody extends StatelessWidget {
  const _StackedMediaCardBody({
    required this.content,
    required this.canAccess,
    required this.canPlay,
    required this.cardSubtitle,
    required this.figuresAsync,
    required this.dateLabel,
    required this.isAudio,
    required this.showsPlayButton,
    required this.handler,
    required this.savedPlayback,
    required this.fallbackDurationMs,
  });

  final Content content;
  final bool canAccess;
  final bool canPlay;
  final String? cardSubtitle;
  final AsyncValue<List<Figure>> figuresAsync;
  final String dateLabel;
  final bool isAudio;
  final bool showsPlayButton;
  final KikikaikaiMediaHandler? handler;
  final ContentPlaybackProgress? savedPlayback;
  final int? fallbackDurationMs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CompactCardThumbnail(
          content: content,
          canAccess: canAccess,
          canPlay: canPlay,
          fullWidth: true,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            CompactCategoryContentCard._contentPadding,
            CompactCategoryContentCard._titleTopSpacingAfterThumb,
            CompactCategoryContentCard._contentPadding,
            CompactCategoryContentCard._contentPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content.title,
                style: CompactCategoryContentCard._titleStyle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              ..._CardTextSections.build(
                content: content,
                cardSubtitle: cardSubtitle,
                figuresAsync: figuresAsync,
                dateLabel: dateLabel,
                isAudio: isAudio,
                showsPlayButton: showsPlayButton,
                handler: handler,
                savedPlayback: savedPlayback,
                fallbackDurationMs: fallbackDurationMs,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardTextSections {
  static List<Widget> build({
    required Content content,
    required String? cardSubtitle,
    required AsyncValue<List<Figure>> figuresAsync,
    required String dateLabel,
    required bool isAudio,
    required bool showsPlayButton,
    required KikikaikaiMediaHandler? handler,
    required ContentPlaybackProgress? savedPlayback,
    required int? fallbackDurationMs,
  }) {
    return [
      if (cardSubtitle != null) ...[
        const SizedBox(height: CompactCategoryContentCard._subtitleTopSpacing),
        Text(
          cardSubtitle,
          style: AppTypography.body(
            size: 13,
            color: AppColors.muted,
            weight: FontWeight.w400,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
      const SizedBox(height: CompactCategoryContentCard._figureVerticalSpacing),
      Padding(
        padding: EdgeInsets.only(
          right: showsPlayButton && !isAudio ? 44 : 0,
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
            accessLabel: content.accessLevel.cardBadgeLabel,
            compact: true,
            showDate: !isAudio,
          ),
        ),
      ),
      if (isAudio)
        Padding(
          padding: EdgeInsets.only(
            top: CompactCategoryContentCard._figureVerticalSpacing,
            right: showsPlayButton ? 44 : 0,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _AudioPlaybackIndicatorSection(
              content: content,
              handler: handler,
              savedPlayback: savedPlayback,
              dateLabel: dateLabel,
              fallbackDurationMs: fallbackDurationMs,
            ),
          ),
        ),
    ];
  }
}

String? _compactCardSubtitle(Content content) {
  final cardSubtitle = content.cardSubtitle?.trim();
  if (cardSubtitle != null && cardSubtitle.isNotEmpty) {
    return cardSubtitle;
  }
  return null;
}

class _HorizontalThumbnailTitleRow extends StatelessWidget {
  const _HorizontalThumbnailTitleRow({
    required this.content,
    required this.canAccess,
    required this.canPlay,
  });

  final Content content;
  final bool canAccess;
  final bool canPlay;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _CompactCardThumbnail(
          content: content,
          canAccess: canAccess,
          canPlay: canPlay,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            content.title,
            style: CompactCategoryContentCard._titleStyle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CompactCardThumbnail extends StatelessWidget {
  const _CompactCardThumbnail({
    required this.content,
    required this.canAccess,
    required this.canPlay,
    this.fullWidth = false,
  });

  final Content content;
  final bool canAccess;
  final bool canPlay;
  final bool fullWidth;

  double get _aspectRatio {
    if (fullWidth) {
      return CompactCategoryContentCard._landscapeThumbAspectRatio;
    }
    return switch (content.type) {
      ContentType.video || ContentType.audio =>
        CompactCategoryContentCard._landscapeThumbAspectRatio,
      _ => 1,
    };
  }

  @override
  Widget build(BuildContext context) {
    final thumbnail = AspectRatio(
      aspectRatio: _aspectRatio,
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
    );

    if (fullWidth) {
      return thumbnail;
    }

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(CompactCategoryContentCard._thumbRadius),
      child: SizedBox(
        width: CompactCategoryContentCard._thumbWidth,
        child: thumbnail,
      ),
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
