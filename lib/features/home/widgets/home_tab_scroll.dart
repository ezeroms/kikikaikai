import 'package:flutter/material.dart';
import 'package:kikikaikai/features/home/widgets/category_profile_header.dart';
import 'package:kikikaikai/features/home/widgets/category_tab_layout.dart';
import 'package:kikikaikai/features/home/widgets/home_category_tab_scroll_scope.dart';
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
/// 正方形ヒーロー背景をタブ直下に固定し、タイトル・説明・カードだけがスクロールする。
Widget buildHomeCategoryTabScroll(
  BuildContext context, {
  required String imageAsset,
  required Widget header,
  required List<Widget> contentCards,
  bool injectNestedScrollOverlap = true,
}) {
  return _CategoryTabScroll(
    imageAsset: imageAsset,
    header: header,
    contentCards: contentCards,
    injectNestedScrollOverlap: injectNestedScrollOverlap,
  );
}

class _CategoryTabScroll extends StatelessWidget {
  const _CategoryTabScroll({
    required this.imageAsset,
    required this.header,
    required this.contentCards,
    required this.injectNestedScrollOverlap,
  });

  final String imageAsset;
  final Widget header;
  final List<Widget> contentCards;
  final bool injectNestedScrollOverlap;

  @override
  Widget build(BuildContext context) {
    final squareSize = MediaQuery.sizeOf(context).width;
    final bottomPadding = 32 + miniPlayerScrollPadding(context);
    final overlapHandle = injectNestedScrollOverlap
        ? NestedScrollView.sliverOverlapAbsorberHandleFor(context)
        : null;
    final outerScrollController =
        HomeCategoryTabScrollScope.maybeOuterScrollControllerOf(context);

    Widget buildBody({required double backgroundTop}) {
      return Stack(
        clipBehavior: Clip.hardEdge,
        fit: StackFit.expand,
        children: [
          Positioned(
            top: backgroundTop,
            left: 0,
            right: 0,
            height: squareSize,
            child: IgnorePointer(
              child: CategoryProfileBackground(
                imageAsset: imageAsset,
              ),
            ),
          ),
          CustomScrollView(
            clipBehavior: Clip.hardEdge,
            slivers: [
              if (overlapHandle != null)
                SliverOverlapInjector(handle: overlapHandle),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    Padding(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var index = 0;
                              index < contentCards.length;
                              index++) ...[
                            if (index > 0) const SizedBox(height: 16),
                            contentCards[index],
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (!injectNestedScrollOverlap || outerScrollController == null) {
      return buildBody(backgroundTop: 0);
    }

    return ListenableBuilder(
      listenable: outerScrollController,
      builder: (context, _) {
        final outerOffset = outerScrollController.hasClients
            ? outerScrollController.offset
            : 0.0;
        return buildBody(
          backgroundTop: categoryTabBackgroundTopInset(outerOffset),
        );
      },
    );
  }
}
