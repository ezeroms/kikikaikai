import 'package:flutter/material.dart';
import 'package:kikikaikai/features/home/widgets/category_profile_header.dart';
import 'package:kikikaikai/shared/widgets/mini_player_bar.dart';

/// ホームタブ用の縦スクロール。NestedScrollView のオーバーラップを吸収する。
Widget buildHomeMainTabScroll(
  BuildContext context,
  List<Widget> children, {
  EdgeInsetsGeometry? padding,
  Widget? header,
}) {
  return CustomScrollView(
    slivers: [
      SliverOverlapInjector(
        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      ),
      if (header != null) SliverToBoxAdapter(child: header),
      SliverPadding(
        padding: padding ??
            EdgeInsets.only(
              bottom: 32 + miniPlayerScrollPadding(context),
            ),
        sliver: SliverList(
          delegate: SliverChildListDelegate(children),
        ),
      ),
    ],
  );
}

/// カテゴリタブ用の縦スクロール。
/// プロフィール背景の上にコンテンツ一覧を重ねるレイアウトを担う。
Widget buildHomeCategoryTabScroll(
  BuildContext context, {
  required Widget header,
  required List<Widget> contentCards,
}) {
  final overlap = CategoryProfileHeader.contentOverlap;
  final headerHeight = MediaQuery.sizeOf(context).width;
  final bottomPadding = 32 + miniPlayerScrollPadding(context);

  final contentList = Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var index = 0; index < contentCards.length; index++) ...[
        if (index > 0) const SizedBox(height: 16),
        contentCards[index],
      ],
    ],
  );

  return CustomScrollView(
    clipBehavior: Clip.none,
    slivers: [
      SliverOverlapInjector(
        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      ),
      SliverToBoxAdapter(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            header,
            Padding(
              padding: EdgeInsets.only(
                top: headerHeight - overlap,
                left: 24,
                right: 24,
                bottom: bottomPadding,
              ),
              child: contentList,
            ),
          ],
        ),
      ),
    ],
  );
}
