import 'package:flutter/material.dart';

const kContentDetailTabContentTopSpacing = 24.0;

/// TabBarView をタブ直下でクリップする詳細画面向けスコープ
class ContentDetailTabScrollScope extends InheritedWidget {
  const ContentDetailTabScrollScope({
    super.key,
    required this.clipsBodyBelowTabBar,
    required super.child,
  });

  final bool clipsBodyBelowTabBar;

  static bool clipsBelowTabBarOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<ContentDetailTabScrollScope>()
            ?.clipsBodyBelowTabBar ??
        false;
  }

  @override
  bool updateShouldNotify(ContentDetailTabScrollScope oldWidget) {
    return clipsBodyBelowTabBar != oldWidget.clipsBodyBelowTabBar;
  }
}

/// NestedScrollView 内タブ用の縦スクロール。オーバーラップを吸収する。
Widget buildContentDetailNestedScroll(
  BuildContext context, {
  required Widget child,
  EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(
    20,
    kContentDetailTabContentTopSpacing,
    20,
    24,
  ),
}) {
  final clipsBelowTabBar = ContentDetailTabScrollScope.clipsBelowTabBarOf(context);

  return CustomScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    clipBehavior: Clip.hardEdge,
    slivers: [
      if (!clipsBelowTabBar)
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
      SliverPadding(
        padding: padding,
        sliver: SliverToBoxAdapter(child: child),
      ),
    ],
  );
}

/// NestedScrollView 内タブ用。Sliver を直接渡す。
Widget buildContentDetailNestedScrollSlivers(
  BuildContext context, {
  required List<Widget> slivers,
}) {
  final clipsBelowTabBar = ContentDetailTabScrollScope.clipsBelowTabBarOf(context);

  return CustomScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    clipBehavior: Clip.hardEdge,
    slivers: [
      if (!clipsBelowTabBar)
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
      ...slivers,
    ],
  );
}
