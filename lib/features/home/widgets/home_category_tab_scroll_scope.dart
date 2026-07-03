import 'package:flutter/material.dart';

/// カテゴリタブ用 — NestedScrollView 外側スクロールコントローラを body へ渡す。
class HomeCategoryTabScrollScope extends InheritedWidget {
  const HomeCategoryTabScrollScope({
    super.key,
    required this.outerScrollController,
    required super.child,
  });

  final ScrollController outerScrollController;

  static ScrollController? maybeOuterScrollControllerOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<HomeCategoryTabScrollScope>()
        ?.outerScrollController;
  }

  @override
  bool updateShouldNotify(HomeCategoryTabScrollScope oldWidget) {
    return outerScrollController != oldWidget.outerScrollController;
  }
}
