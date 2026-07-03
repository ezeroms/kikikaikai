import 'package:kikikaikai/features/home/widgets/home_logo_header_sliver.dart';
import 'package:kikikaikai/features/home/widgets/home_pill_tab_bar.dart';

/// NestedScrollView の外側スクロール量から、カテゴリタブ固定背景の top を求める。
///
/// ロゴ折りたたみ中 (0..logoHeight) は body 上端とタブ下端が一体で動くため 0。
/// ロゴが消えたあと body がタブ直下へ引き上げられる間 (logoHeight..logoHeight+tabHeight)
/// だけ inset を 0..tabHeight へ増やす。
double categoryTabBackgroundTopInset(double outerScrollOffset) {
  if (outerScrollOffset <= HomeLogoHeader.height) {
    return 0;
  }
  return (outerScrollOffset - HomeLogoHeader.height)
      .clamp(0.0, HomePillTabBar.height);
}

/// ロゴ＋タブ分の折りたたみが完了した外側スクロール量。
double get categoryTabHeaderCollapseExtent =>
    HomeLogoHeader.height + HomePillTabBar.height;
