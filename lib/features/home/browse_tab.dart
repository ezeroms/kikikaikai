import 'package:kikikaikai/core/models/content_type.dart';

enum BrowseTab {
  home,
  kikikaikai,
  bulletin,
  radio,
  tv,
  manuscript;

  String get label => switch (this) {
        BrowseTab.home => 'ホーム',
        BrowseTab.kikikaikai => '奇奇怪怪',
        BrowseTab.bulletin => '回覧板',
        BrowseTab.radio => 'ラジオ',
        BrowseTab.tv => 'テレビ',
        BrowseTab.manuscript => '玉稿',
      };

  ContentType? get contentType => switch (this) {
        BrowseTab.home => null,
        BrowseTab.kikikaikai => ContentType.kikikaikai,
        BrowseTab.bulletin => ContentType.bulletin,
        BrowseTab.radio => ContentType.audio,
        BrowseTab.tv => ContentType.video,
        BrowseTab.manuscript => ContentType.manuscript,
      };
}
