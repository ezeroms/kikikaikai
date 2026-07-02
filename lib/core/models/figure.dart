/// コンテンツにタグ付けされる人物（執筆・出演・進行など）。
///
/// 一般ユーザー [AppUser] とは別のデータベースで管理する。
class Figure {
  const Figure({
    required this.id,
    required this.name,
    required this.sortKey,
    required this.bio,
    required this.avatarAsset,
  });

  final String id;
  final String name;

  /// 五十音順ソート用（ひらがな）
  final String sortKey;
  final String bio;
  final String avatarAsset;
}

/// Figure を五十音順（sortKey）で並べ替える
List<Figure> sortFiguresByGojuon(Iterable<Figure> figures) {
  return figures.toList()..sort((a, b) => a.sortKey.compareTo(b.sortKey));
}
