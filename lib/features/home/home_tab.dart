import 'package:kikikaikai/core/models/content_type.dart';

/// 鑑賞画面（HomeScreen）上部の横スクロールタブ
enum HomeTab {
  home,
  kikikaikai,
  bulletin,
  radio,
  tv,
  manuscript;

  String get label => switch (this) {
        HomeTab.home => 'ホーム',
        HomeTab.kikikaikai => '奇奇怪怪',
        HomeTab.bulletin => '回覧板',
        HomeTab.radio => 'ラジオ',
        HomeTab.tv => 'テレビ',
        HomeTab.manuscript => '玉稿',
      };

  ContentType? get contentType => switch (this) {
        HomeTab.home => null,
        HomeTab.kikikaikai => ContentType.kikikaikai,
        HomeTab.bulletin => ContentType.bulletin,
        HomeTab.radio => ContentType.audio,
        HomeTab.tv => ContentType.video,
        HomeTab.manuscript => ContentType.manuscript,
      };

  /// カテゴリタブ上部プロフィール用ヒーロー画像
  String? get profileHeroAsset => switch (this) {
        HomeTab.home => null,
        HomeTab.kikikaikai => 'assets/bg/kikikaikai.png',
        HomeTab.bulletin => 'assets/bg/kairanban.png',
        HomeTab.radio => 'assets/bg/radio.png',
        HomeTab.tv => 'assets/bg/tv.png',
        HomeTab.manuscript => 'assets/bg/gyokko.png',
      };

  /// カテゴリタブ上部プロフィール用説明文
  String get profileDescription => switch (this) {
        HomeTab.home => '',
        HomeTab.kikikaikai => 'ガンダーラを漂う耳の旅',
        HomeTab.bulletin =>
          '日々を薄く支配する言葉を起点に、タイタンの仮説を記録する。週3回更新。だから基本乱文御免。',
        HomeTab.radio =>
          'タイタンが今話したい人を呼んで、適切な雑談をする場。濃い場合が多い。団地なのでジャンルレスで面白い人が集まる。団地なのだから。割と定期的に更新される予定。',
        HomeTab.tv =>
          'タイタン/玉置/カンベの旅を映像で記録したりする。やがて専用車を買って、全国行脚するのが野望。JEEPがいい。',
        HomeTab.manuscript =>
          '玉置周啓の珠玉の善玉の玉に瑕な玉稿エッセイ集。週1回更新。玉稿。',
      };
}
