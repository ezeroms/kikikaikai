import 'package:flutter/material.dart';

/// インライン動画プレーヤー向けの再生／一時停止ボタン
class InlineVideoPlayButton extends StatelessWidget {
  const InlineVideoPlayButton({
    super.key,
    required this.onPressed,
    this.playing = false,
    this.size = 72,
  });

  final VoidCallback? onPressed;
  final bool playing;
  final double size;

  @override
  Widget build(BuildContext context) {
    final iconSize = size * (playing ? 0.56 : 0.61);

    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: playing
                ? Icon(
                    Icons.pause_rounded,
                    color: Colors.white,
                    size: iconSize,
                  )
                : Padding(
                    padding: EdgeInsets.only(left: size * 0.055),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: iconSize,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
