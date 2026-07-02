import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';

/// カード上のタイトル＋任意のサブテキスト
class ContentCardTextBlock extends StatelessWidget {
  const ContentCardTextBlock({
    super.key,
    required this.title,
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.subtitleMaxLines = 2,
    this.textAlign = TextAlign.start,
    this.titleSubtitleGap = 8,
  });

  final String title;
  final String? subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final int subtitleMaxLines;
  final TextAlign textAlign;
  final double titleSubtitleGap;

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;
    final align = textAlign == TextAlign.center
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          title,
          style: titleStyle ?? AppTypography.titleSmall(size: 16),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
        ),
        if (hasSubtitle) ...[
          SizedBox(height: titleSubtitleGap),
          Text(
            subtitle!,
            style: subtitleStyle ??
                AppTypography.body(
                  size: 14,
                  color: AppColors.muted,
                  weight: FontWeight.w400,
                ),
            maxLines: subtitleMaxLines,
            overflow: TextOverflow.ellipsis,
            textAlign: textAlign,
          ),
        ],
      ],
    );
  }
}
