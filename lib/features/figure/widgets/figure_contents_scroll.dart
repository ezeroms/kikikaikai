import 'package:flutter/material.dart';
import 'package:kikikaikai/core/models/figure.dart';
import 'package:kikikaikai/features/figure/widgets/figure_profile_header.dart';
import 'package:kikikaikai/shared/widgets/mini_player_bar.dart';

/// Figure コンテンツエリア（背景画像固定＋内部スクロール）。
Widget buildFigureContentsArea(
  BuildContext context, {
  required Figure figure,
  required List<Widget> contentCards,
}) {
  final bottomPadding = 32 + miniPlayerScrollPadding(context);

  return Expanded(
    child: Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: FigureContentBackground(figure: figure),
          ),
        ),
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: FigureScrollProfile(figure: figure),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPadding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index.isOdd) {
                      return const SizedBox(height: 16);
                    }
                    return contentCards[index ~/ 2];
                  },
                  childCount: contentCards.isEmpty
                      ? 0
                      : contentCards.length * 2 - 1,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}