import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/features/content/widgets/tv_player_widget.dart';
import 'package:kikikaikai/shared/widgets/figure_meta_row.dart';

/// 街頭テレビ詳細のスクロール可能ヘッダー（プレーヤー・タイトル・Figure）
class VideoDetailHeader extends ConsumerWidget {
  const VideoDetailHeader({
    super.key,
    required this.content,
    required this.canAccess,
    required this.previewOnly,
    required this.showVideoPlayer,
  });

  final Content content;
  final bool canAccess;
  final bool previewOnly;
  final bool showVideoPlayer;

  TextStyle get _figureNameStyle => AppTypography.titleSmall(size: 12).copyWith(
        fontWeight: FontWeight.w400,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final figuresAsync = ref.watch(contentFiguresProvider(content.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showVideoPlayer)
          TvPlayerWidget(
            key: ValueKey(content.id),
            content: content,
            previewLimit: previewOnly ? const Duration(seconds: 30) : null,
            edgeToEdge: true,
            margin: EdgeInsets.zero,
          )
        else
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              content.displayThumbnail,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                content.title,
                style: AppTypography.title(
                  size: 26,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              figuresAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (figures) => FigureMetaRow(
                  figures: figures,
                  dateLabel: '',
                  showDate: false,
                  compact: true,
                  avatarRadius: 12,
                  metaFontSize: 12,
                  nameStyle: _figureNameStyle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
