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

  static const _recommendedCarouselTypes = {
    ContentType.audio,
    ContentType.video,
    ContentType.kikikaikai,
    ContentType.manuscript,
  };

  /// 投稿日の新しい順に並べ替えたコピーを返す。
  static List<Content> sortByPublishedAtDesc(List<Content> contents) {
    return [...contents]..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  }

  static List<Content> _sorted(Iterable<Content> items) {
    return sortByPublishedAtDesc(items.toList());
  }

  static List<Content> _eligible(List<Content> all) {
    return _sorted(all.where((c) => _featuredTypes.contains(c.type)));
  }

  /// おすすめ（大きな縦カード）— 回覧板は除外し、テレビ・ラジオを含める
  static List<Content> recommended(List<Content> all) {
    final result = <Content>[];
    final used = <String>{};

    for (final type in [
      ContentType.video,
      ContentType.audio,
      ContentType.kikikaikai,
      ContentType.manuscript,
    ]) {
      final latest = _sorted(all.where((c) => c.type == type)).firstOrNull;
      if (latest != null && used.add(latest.id)) {
        result.add(latest);
      }
    }

    for (final content in _sorted(
      all.where((c) => _recommendedCarouselTypes.contains(c.type)),
    )) {
      if (result.length >= 5) break;
      if (used.add(content.id)) result.add(content);
    }

    result.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return result;
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

  /// おすすめ対象から循環的に切り出す（セクション見出し用の仮割り当て）
  static List<Content> _rotatedFeaturedSlice(
    List<Content> all, {
    required int startIndex,
    required int count,
  }) {
    final items = _eligible(all);
    if (items.isEmpty) return [];
    return [
      for (var i = 0; i < count; i++) items[(startIndex + i) % items.length],
    ];
  }

  static List<Content> _byIds(List<Content> all, List<String> ids) {
    final byId = {for (final content in all) content.id: content};
    return [
      for (final id in ids)
        if (byId[id] != null) byId[id]!,
    ];
  }

  /// はじめて見る人 — 各カテゴリの入門として回れる固定キュレーション（回覧板は含めない）
  static const _newcomerContentIds = [
    'c016', // 奇奇怪怪
    'c004', // 団地ラジオ
    'c015', // 団地ラジオ
    'c006', // 街頭テレビ
    'c008', // 玉置玉稿
    'c017', // 奇奇怪怪
  ];

  static List<Content> newcomers(List<Content> all) {
    return _byIds(all, _newcomerContentIds)
        .where((content) => content.type != ContentType.bulletin)
        .toList();
  }

  /// 音楽セクション — 団地ラジオと奇奇怪怪
  static List<Content> audioAndPodcast(List<Content> all) {
    return _byTypes(all, {ContentType.audio, ContentType.kikikaikai});
  }

  /// 映画セクション — 街頭テレビ
  static List<Content> video(List<Content> all) {
    return _byTypes(all, {ContentType.video});
  }

  /// 本セクション — 玉置玉稿
  static List<Content> manuscript(List<Content> all) {
    return _byTypes(all, {ContentType.manuscript});
  }

  /// ファッションセクション — 仮の循環割り当て
  static List<Content> fashionPlaceholder(List<Content> all) {
    return _rotatedFeaturedSlice(all, startIndex: 0, count: 6);
  }

  /// 政治・社会セクション — 回覧板
  static List<Content> bulletin(List<Content> all) {
    return _byTypes(all, {ContentType.bulletin});
  }

  /// ビジネスセクション — 回覧板・団地便・旧作倉庫
  static List<Content> shopArchiveAndBulletin(List<Content> all) {
    return _sorted(
      all.where(
        (c) =>
            c.type == ContentType.bulletin ||
            c.type == ContentType.shop ||
            c.type == ContentType.archive,
      ),
    ).take(6).toList();
  }

  /// 野球セクション — 仮の循環割り当て
  static List<Content> baseballPlaceholder(List<Content> all) {
    return _rotatedFeaturedSlice(all, startIndex: 4, count: 6);
  }

  static const sections = <({String? title, List<Content> Function(List<Content>) items})>[
    (title: '新着', items: newest),
    (title: 'はじめて見る人', items: newcomers),
    (title: '音楽', items: audioAndPodcast),
    (title: '映画', items: video),
    (title: '本', items: manuscript),
    (title: 'ファッション', items: fashionPlaceholder),
    (title: '政治・社会', items: bulletin),
    (title: 'ビジネス', items: shopArchiveAndBulletin),
    (title: '野球', items: baseballPlaceholder),
  ];
}
