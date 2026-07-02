import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';

const _kDefaultAvatarAsset = 'assets/branding/eye_catch/mypage.png';

class CommentAuthorAvatar extends StatelessWidget {
  const CommentAuthorAvatar({
    super.key,
    this.avatarAsset,
    this.radius = 18,
  });

  final String? avatarAsset;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.surfaceElevated,
      backgroundImage: AssetImage(avatarAsset ?? _kDefaultAvatarAsset),
    );
  }
}
