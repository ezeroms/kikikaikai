import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/models/author.dart';

/// [アイコン] [名前] [投稿日]
class AuthorMetaRow extends StatelessWidget {
  const AuthorMetaRow({
    super.key,
    required this.author,
    required this.dateLabel,
    this.avatarRadius = 12,
  });

  final Author? author;
  final String dateLabel;
  final double avatarRadius;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: AppColors.darkSurface,
          backgroundImage: author != null
              ? AssetImage(author!.avatarAsset)
              : null,
          child: author == null
              ? Icon(LucideIcons.user, size: avatarRadius)
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          author?.name ?? '不明',
          style: AppTypography.label(size: 12, weight: FontWeight.w400),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(width: 8),
        Text(
          dateLabel,
          style: AppTypography.caption(size: 11),
        ),
      ],
    );
  }
}
