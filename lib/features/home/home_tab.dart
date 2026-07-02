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
        HomeTab.kikikaikai => 'ポップカルチャーと団地の夜を、TaiTan と玉置が語るポッドキャスト。',
        HomeTab.bulletin => '週3回更新。団地の出来事や設計図、基本乱文御免。',
        HomeTab.radio => '団地ラジオ。エレベーター点検の裏側から、闇市の夜まで。',
        HomeTab.tv => '街頭テレビ。路上から届くインタビューと記録。',
        HomeTab.manuscript => '玉置玉稿。団地の階段と都市伝説をめぐるエッセイ。',
      };
}
