enum ContentType {
  bulletin,
  manuscript,
  video,
  audio,
  kikikaikai,
  shop,
  archive;

  String get label => switch (this) {
        ContentType.bulletin => '回覧板',
        ContentType.manuscript => '玉置玉稿',
        ContentType.video => '街頭テレビ',
        ContentType.audio => '団地ラジオ',
        ContentType.kikikaikai => '奇奇怪怪',
        ContentType.shop => '団地便',
        ContentType.archive => '旧作倉庫',
      };

  bool get isAudioPlayback =>
      this == ContentType.audio || this == ContentType.kikikaikai;

  bool get isTextArticle =>
      this == ContentType.bulletin || this == ContentType.manuscript;

  /// 詳細画面で「書き起こし」タブを表示する（奇奇怪怪・ラジオ）
  bool get hasTranscriptTab => isAudioPlayback;

  /// 詳細画面で本編・コメント（＋任意で書き起こし）タブを使う
  bool get usesTabbedDetail =>
      isAudioPlayback || this == ContentType.video || isTextArticle;

  bool get usesCompactCategoryCard => isTextArticle || isAudioPlayback;

  String get iconAsset => switch (this) {
        ContentType.bulletin => 'assets/branding/eye_catch/kairanban.png',
        ContentType.manuscript => 'assets/branding/eye_catch/gyokko.png',
        ContentType.video => 'assets/branding/eye_catch/gaitotv.png',
        ContentType.audio => 'assets/branding/eye_catch/gaitoradio.png',
        ContentType.kikikaikai => 'assets/branding/ogp_common.png',
        ContentType.shop => 'assets/branding/eye_catch/danchiletter.png',
        ContentType.archive => 'assets/branding/eye_catch/kyusakusoko.png',
      };

  String get routePath => switch (this) {
        ContentType.bulletin => '/kairanban',
        ContentType.manuscript => '/gyokko',
        ContentType.video => '/gaitotv',
        ContentType.audio => '/gaitoradio',
        ContentType.kikikaikai => '/kikikaikai',
        ContentType.shop => '/danchiletter',
        ContentType.archive => '/kyusakusoko',
      };
}
