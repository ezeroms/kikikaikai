import 'package:kikikaikai/core/models/access_level.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_type.dart';

/// ホームタブのセクション定義とコンテンツ割り当て
abstract final class HomeFeed {
  static const _featuredTypes = {
    ContentType.bulletin,
    ContentType.audio,
    ContentType.kikikaikai,
    ContentType.video,
    ContentType.manuscript,
  };

  static List<Content> _sorted(Iterable<Content> items) {
    return [...items]..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  }

  static List<Content> _eligible(List<Content> all) {
    return _sorted(all.where((c) => _featuredTypes.contains(c.type)));
  }

  /// おすすめ（大きな縦カード）
  static List<Content> recommended(List<Content> all) {
    return _eligible(all).take(5).toList();
  }

  /// 新着
  static List<Content> newest(List<Content> all) {
    return _eligible(all).take(8).toList();
  }

  static List<Content> _byTypes(List<Content> all, Set<ContentType> types) {
    return _sorted(
      all.where((c) => types.contains(c.type)),
    ).take(6).toList();
  }

  static List<Content> _slice(List<Content> all, int start, int count) {
    final items = _eligible(all);
    if (items.isEmpty) return [];
    return [
      for (var i = 0; i < count; i++) items[(start + i) % items.length],
    ];
  }

  static List<Content> newcomers(List<Content> all) {
    return _sorted(
      all.where(
        (c) =>
            _featuredTypes.contains(c.type) &&
            c.accessLevel == AccessLevel.public,
      ),
    ).take(6).toList();
  }

  static List<Content> music(List<Content> all) {
    return _byTypes(all, {ContentType.audio, ContentType.kikikaikai});
  }

  static List<Content> film(List<Content> all) {
    return _byTypes(all, {ContentType.video});
  }

  static List<Content> books(List<Content> all) {
    return _byTypes(all, {ContentType.manuscript});
  }

  static List<Content> fashion(List<Content> all) {
    return _slice(all, 0, 6);
  }

  static List<Content> politics(List<Content> all) {
    return _byTypes(all, {ContentType.bulletin});
  }

  static List<Content> business(List<Content> all) {
    return _sorted(
      all.where(
        (c) =>
            c.type == ContentType.bulletin ||
            c.type == ContentType.shop ||
            c.type == ContentType.archive,
      ),
    ).take(6).toList();
  }

  static List<Content> baseball(List<Content> all) {
    return _slice(all, 4, 6);
  }

  static const sections = <({String? title, List<Content> Function(List<Content>) items})>[
    (title: '新着', items: newest),
    (title: 'はじめて見る人', items: newcomers),
    (title: '音楽', items: music),
    (title: '映画', items: film),
    (title: '本', items: books),
    (title: 'ファッション', items: fashion),
    (title: '政治・社会', items: politics),
    (title: 'ビジネス', items: business),
    (title: '野球', items: baseball),
  ];
}
