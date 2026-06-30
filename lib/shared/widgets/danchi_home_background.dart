import 'package:flutter/material.dart';

class DanchiHomeBackground extends StatelessWidget {
  const DanchiHomeBackground({
    super.key,
    required this.child,
    this.showOverlay = true,
  });

  final Widget child;
  final bool showOverlay;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/branding/bg_home_mobile.png',
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        if (showOverlay)
          Container(
            color: Colors.black.withValues(alpha: 0.35),
          ),
        child,
      ],
    );
  }
}
