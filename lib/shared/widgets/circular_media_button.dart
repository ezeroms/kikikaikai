import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';

/// 一般的なメディアプレーヤー風の円形再生／一時停止ボタン
class CircularMediaButton extends StatelessWidget {
  const CircularMediaButton({
    super.key,
    required this.onPressed,
    this.playing,
    this.size = 48,
    this.iconColor,
    this.borderColor,
    this.backgroundColor,
    this.borderWidth = 0,
  });

  /// `null` のときは常に再生アイコン
  final VoidCallback? onPressed;
  final bool? playing;
  final double size;
  final Color? iconColor;
  final Color? borderColor;
  final Color? backgroundColor;
  final double borderWidth;

  static const _spotifyBackground = Colors.white;
  static const _spotifyIcon = AppColors.base;

  /// サムネイル上など（白枠・半透明背景）
  factory CircularMediaButton.overlay({
    Key? key,
    required VoidCallback? onPressed,
    bool? playing,
    double size = 56,
  }) {
    return CircularMediaButton(
      key: key,
      onPressed: onPressed,
      playing: playing,
      size: size,
      iconColor: AppColors.onBase,
      borderColor: AppColors.onBase,
      backgroundColor: Colors.black.withValues(alpha: 0.45),
      borderWidth: 2,
    );
  }

  /// プレーヤーコントロール（白丸・黒アイコン）
  factory CircularMediaButton.control({
    Key? key,
    required VoidCallback? onPressed,
    required bool playing,
    double size = 52,
  }) {
    return CircularMediaButton(
      key: key,
      onPressed: onPressed,
      playing: playing,
      size: size,
      iconColor: _spotifyIcon,
      backgroundColor: _spotifyBackground,
    );
  }

  /// カード内コンパクトサイズ（白丸・黒アイコン）
  factory CircularMediaButton.compact({
    Key? key,
    required VoidCallback? onPressed,
    bool? playing,
  }) {
    return CircularMediaButton(
      key: key,
      onPressed: onPressed,
      playing: playing,
      size: 36,
      iconColor: _spotifyIcon,
      backgroundColor: _spotifyBackground,
    );
  }

  /// ミニプレーヤー（白丸・黒アイコン）
  factory CircularMediaButton.mini({
    Key? key,
    required VoidCallback? onPressed,
    required bool playing,
  }) {
    return CircularMediaButton(
      key: key,
      onPressed: onPressed,
      playing: playing,
      size: 40,
      iconColor: _spotifyIcon,
      backgroundColor: _spotifyBackground,
    );
  }

  @override
  Widget build(BuildContext context) {
    final showPause = playing == true;
    final resolvedIconColor = iconColor ?? _spotifyIcon;
    final resolvedBackgroundColor = backgroundColor ?? _spotifyBackground;
    final iconSize = size * (showPause ? 0.58 : 0.65);

    return Material(
      color: resolvedBackgroundColor,
      shape: CircleBorder(
        side: borderWidth > 0
            ? BorderSide(
                color: borderColor ?? AppColors.onBase,
                width: borderWidth,
              )
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: showPause
                ? Icon(
                    Icons.pause_rounded,
                    size: iconSize,
                    color: resolvedIconColor,
                  )
                : Padding(
                    padding: EdgeInsets.only(left: size * 0.05),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: iconSize,
                      color: resolvedIconColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
