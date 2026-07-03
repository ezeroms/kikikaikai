import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/models/figure.dart';

/// Figure チップ同士の横方向の間隔
const _figureChipSpacing = 20.0;

/// [Figure chips] …… [投稿日] [任意: アクセスラベル]
///
/// 複数 Figure は五十音順に左から並ぶ。各名前をタップで関連コンテンツ一覧へ。
class FigureMetaRow extends StatelessWidget {
  const FigureMetaRow({
    super.key,
    required this.figures,
    required this.dateLabel,
    this.avatarRadius = 12,
    this.metaFontSize = 12,
    this.accessLabel,
    this.nameStyle,
    this.compact = false,
    this.showDate = true,
  });

  final List<Figure> figures;
  final String dateLabel;
  final double avatarRadius;
  final double metaFontSize;
  final String? accessLabel;
  final TextStyle? nameStyle;

  /// コンパクトカード向け — チップ間隔を詰める
  final bool compact;

  /// 日付表示（音声カードで再生インジケーター側に出すときは false）
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final metaStyle = AppTypography.label(
      size: metaFontSize,
      weight: FontWeight.w400,
    );
    final dateStyle = AppTypography.body(
      size: metaFontSize,
      color: AppColors.muted,
      weight: FontWeight.w400,
    );

    final chipSpacing = compact ? 12.0 : _figureChipSpacing;
    final resolvedNameStyle = nameStyle ?? metaStyle;

    if (compact) {
      return _CompactFigureMetaRow(
        figures: figures,
        dateLabel: dateLabel,
        dateStyle: dateStyle,
        avatarRadius: avatarRadius,
        nameStyle: resolvedNameStyle,
        accessLabel: accessLabel,
        showDate: showDate,
        chipSpacing: chipSpacing,
      );
    }

    final children = <Widget>[
      if (figures.isEmpty)
        Text(
          '不明',
          style: resolvedNameStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        )
      else
        for (final figure in figures)
          FigureLinkChip(
            figure: figure,
            avatarRadius: avatarRadius,
            nameStyle: resolvedNameStyle,
          ),
      if (showDate)
        Text(
          dateLabel,
          style: dateStyle,
        ),
      if (accessLabel != null && accessLabel!.isNotEmpty)
        _AccessLabel(text: accessLabel!),
    ];

    if (children.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: chipSpacing,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

/// コンパクトカード向け — Figure ブロックと「日付＋ラベル」ブロックで改行する
class _CompactFigureMetaRow extends StatelessWidget {
  const _CompactFigureMetaRow({
    required this.figures,
    required this.dateLabel,
    required this.dateStyle,
    required this.avatarRadius,
    required this.nameStyle,
    required this.accessLabel,
    required this.showDate,
    required this.chipSpacing,
  });

  final List<Figure> figures;
  final String dateLabel;
  final TextStyle dateStyle;
  final double avatarRadius;
  final TextStyle nameStyle;
  final String? accessLabel;
  final bool showDate;
  final double chipSpacing;

  static const _dateLabelSpacing = 8.0;
  static const _runSpacing = 8.0;

  @override
  Widget build(BuildContext context) {
    final figureGroup = figures.isEmpty
        ? Text(
            '不明',
            style: nameStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        : Wrap(
            spacing: chipSpacing,
            runSpacing: _runSpacing,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final figure in figures)
                FigureLinkChip(
                  figure: figure,
                  avatarRadius: avatarRadius,
                  nameStyle: nameStyle,
                ),
            ],
          );

    final hasTrailingMeta =
        showDate || (accessLabel != null && accessLabel!.isNotEmpty);

    if (!hasTrailingMeta) return figureGroup;

    final trailingMeta = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showDate)
          Text(
            dateLabel,
            style: dateStyle,
          ),
        if (accessLabel != null && accessLabel!.isNotEmpty) ...[
          if (showDate) const SizedBox(width: _dateLabelSpacing),
          _AccessLabel(text: accessLabel!),
        ],
      ],
    );

    return Wrap(
      spacing: chipSpacing,
      runSpacing: _runSpacing,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        figureGroup,
        trailingMeta,
      ],
    );
  }
}

/// Figure 名をタップして関連コンテンツ一覧へ遷移するチップ
class FigureLinkChip extends StatelessWidget {
  const FigureLinkChip({
    super.key,
    required this.figure,
    required this.avatarRadius,
    required this.nameStyle,
  });

  final Figure figure;
  final double avatarRadius;
  final TextStyle nameStyle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/home/figure/${figure.id}'),
        borderRadius: BorderRadius.circular(6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: AppColors.surfaceElevated,
              backgroundImage: AssetImage(figure.avatarAsset),
            ),
            const SizedBox(width: 8),
            Text(
              figure.name,
              style: nameStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class FigureMetaAccessLabel extends StatelessWidget {
  const FigureMetaAccessLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTypography.label(
          size: 10,
          color: AppColors.accent,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AccessLabel extends StatelessWidget {
  const _AccessLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => FigureMetaAccessLabel(text: text);
}

/// フィーチャーカードなど、日付なしの Figure リンク（複数対応）
class FigureLinks extends StatelessWidget {
  const FigureLinks({
    super.key,
    required this.figures,
    this.avatarRadius = 12,
    this.centered = false,
  });

  final List<Figure> figures;
  final double avatarRadius;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    if (figures.isEmpty) return const SizedBox.shrink();

    final linkNameStyle = AppTypography.titleSmall(size: 13).copyWith(
      fontWeight: FontWeight.w400,
    );

    return Wrap(
      alignment: centered ? WrapAlignment.center : WrapAlignment.start,
      spacing: _figureChipSpacing,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final figure in figures)
          FigureLinkChip(
            figure: figure,
            avatarRadius: avatarRadius,
            nameStyle: linkNameStyle,
          ),
      ],
    );
  }
}
