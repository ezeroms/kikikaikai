enum AccessLevel {
  public,
  member,
  resident;

  String get label => switch (this) {
        AccessLevel.public => '誰でも',
        AccessLevel.member => '会員限定',
        AccessLevel.resident => '団地住民限定',
      };

  /// コンテンツカード右下に出すアクセス制限バッジ。
  /// public 以外は現状どおり「団地住民限定」で統一表示する。
  String? get cardBadgeLabel => switch (this) {
        AccessLevel.public => null,
        AccessLevel.member || AccessLevel.resident => '団地住民限定',
      };
}
