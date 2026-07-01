import 'package:kikikaikai/core/models/access_level.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_type.dart';

String _banner(int n) => 'assets/banner/sample-banner_$n.png';

const _kikikaikaiBanner = 'assets/banner/sample-banner_1.png';
const _bulletinBanner = 'assets/banner/sample-banner_2.png';
const _manuscriptBanner = 'assets/banner/sample-banner_3.png';
const _ogp = 'assets/branding/ogp_common.png';

final dummyContents = <Content>[
  Content(
    id: 'c001',
    type: ContentType.bulletin,
    accessLevel: AccessLevel.public,
    title: 'PINPIN MART 復活',
    description: '闇市の品品団地、小売部門が復活した。',
    cardSubtitle: '闇市の品品団地、小売部門が復活した。',
    authorId: 'author_taitan',
    publishedAt: DateTime(2026, 6, 28),
    thumbnailAsset: _bulletinBanner,
    bodyMarkdown: '''
# PINPIN MART 復活

闇市の品品団地、小売部門が復活した。

週3回更新の回覧板より。基本乱文御免。

> 進行中/構想中の企画の設計図やメモも記録する。
''',
  ),
  Content(
    id: 'c002',
    type: ContentType.bulletin,
    accessLevel: AccessLevel.member,
    title: '企画の設計図：第3回',
    description: '空想段階の企画の裏側を公開する。',
    authorId: 'author_taitan',
    publishedAt: DateTime(2026, 6, 25),
    thumbnailAsset: _bulletinBanner,
    bodyMarkdown: '''
# 企画の設計図：第3回

企画の立て方に興味がある人が読んでも面白いかもしれない。

1. まず雑談する
2. 面白いことを見つける
3. それを番組にする
''',
  ),
  Content(
    id: 'c003',
    type: ContentType.bulletin,
    accessLevel: AccessLevel.resident,
    title: '管理室の記録',
    description: '団地住民限定の内部記録。',
    authorId: 'author_taitan',
    publishedAt: DateTime(2026, 6, 20),
    thumbnailAsset: _bulletinBanner,
    bodyMarkdown: '''
# 管理室の記録

団地住民限定。

地下の密談は漏れない。特に内容の制限もない。
''',
  ),
  Content(
    id: 'c004',
    type: ContentType.audio,
    accessLevel: AccessLevel.member,
    title: 'ポップカルチャーと団地（前編）',
    description: 'タイタンがゲストを呼んで、今のポップカルチャーについて考える。前半。',
    cardSubtitle: 'ゲストと語る、ポップカルチャーと団地の話。',
    authorId: 'author_paon',
    publishedAt: DateTime(2026, 6, 22),
    thumbnailAsset: _banner(4),
    mediaUrl: 'assets/audio/radio_01.mp3',
  ),
  Content(
    id: 'c005',
    type: ContentType.audio,
    accessLevel: AccessLevel.resident,
    title: 'ポップカルチャーと団地（後編）',
    description: '団地住民限定。同じ回の後半パート。',
    authorId: 'author_paon',
    publishedAt: DateTime(2026, 6, 22),
    thumbnailAsset: _banner(5),
    mediaUrl: 'assets/audio/radio_02.mp3',
  ),
  Content(
    id: 'c006',
    type: ContentType.video,
    accessLevel: AccessLevel.member,
    title: '街頭インタビュー #7（前半）',
    description: '街頭テレビ、路上からの配信。前半は無料会員まで。',
    cardSubtitle: '街頭テレビ、路上からの配信。',
    authorId: 'author_paon',
    publishedAt: DateTime(2026, 6, 18),
    thumbnailAsset: _banner(12),
    mediaUrl: 'assets/video/tv_01.mp4',
  ),
  Content(
    id: 'c007',
    type: ContentType.video,
    accessLevel: AccessLevel.resident,
    title: '街頭インタビュー #7（後半）',
    description: '団地住民限定。同じ回の後半パート。',
    authorId: 'author_paon',
    publishedAt: DateTime(2026, 6, 18),
    thumbnailAsset: _banner(13),
    mediaUrl: 'assets/video/tv_02.mp4',
  ),
  Content(
    id: 'c008',
    type: ContentType.manuscript,
    accessLevel: AccessLevel.member,
    title: '都市伝説の系譜学',
    description: '玉置玉稿、エッセイ連載。',
    cardSubtitle: '団地の階段と都市伝説をめぐるエッセイ。',
    authorId: 'author_tamaki',
    publishedAt: DateTime(2026, 6, 12),
    thumbnailAsset: _manuscriptBanner,
    bodyMarkdown: '''
# 都市伝説の系譜学

団地の階段には、消える段があるという。

それは都市伝説ではなく、ただの団地の性質だ。
''',
  ),
  Content(
    id: 'c009',
    type: ContentType.manuscript,
    accessLevel: AccessLevel.resident,
    title: '玉稿：夜の便所詩',
    description: '団地住民限定の玉稿。',
    authorId: 'author_tamaki',
    publishedAt: DateTime(2026, 6, 8),
    thumbnailAsset: _manuscriptBanner,
    bodyMarkdown: '''
# 玉稿：夜の便所詩

```
蛍光灯の下で
団地は眠らない
```
''',
  ),
  Content(
    id: 'c010',
    type: ContentType.shop,
    accessLevel: AccessLevel.resident,
    title: '『二十』KV Tee',
    description: '団地限定の珍品。気まぐれで予告する予定。',
    authorId: 'author_kanri',
    publishedAt: DateTime(2026, 5, 20),
    thumbnailAsset: _ogp,
    bodyMarkdown: '''
# 『二十』KV Tee

団地限定の珍品を販売する。

※URLのご共有はご遠慮ください
''',
    externalUrl: 'https://pinpin.tokyo/danchiletter',
  ),
  Content(
    id: 'c011',
    type: ContentType.shop,
    accessLevel: AccessLevel.resident,
    title: '団地ざぶ',
    description: '団地の座布団。ざぶ。',
    authorId: 'author_kanri',
    publishedAt: DateTime(2026, 5, 15),
    thumbnailAsset: _ogp,
    bodyMarkdown: '''
# 団地ざぶ

団地の座布団。ざぶ。クッション的に使うのもいいだろう。
''',
    externalUrl: 'https://pinpin.tokyo/danchiletter',
  ),
  Content(
    id: 'c012',
    type: ContentType.archive,
    accessLevel: AccessLevel.member,
    title: '2024 アーカイブ',
    description: '旧作倉庫、過去のコンテンツ。',
    authorId: 'author_kanri',
    publishedAt: DateTime(2025, 12, 31),
    thumbnailAsset: _ogp,
    bodyMarkdown: '''
# 2024 アーカイブ

2024年の団地ラジオ、街頭テレビ、回覧板のアーカイブ一覧。

- 団地ラジオ #1〜#48
- 街頭テレビ #1〜#12
- 回覧板 週3更新 × 52週
''',
  ),
  Content(
    id: 'c013',
    type: ContentType.archive,
    accessLevel: AccessLevel.resident,
    title: '地下記録 2023',
    description: '団地住民限定アーカイブ。',
    authorId: 'author_kanri',
    publishedAt: DateTime(2024, 1, 1),
    thumbnailAsset: _ogp,
    bodyMarkdown: '''
# 地下記録 2023

地下なので密談は漏れない。
''',
  ),
  Content(
    id: 'c014',
    type: ContentType.bulletin,
    accessLevel: AccessLevel.public,
    title: '【回覧板】エレベーター点検のお知らせ',
    description: '来週火曜日、エレベーター点検を実施します。',
    cardSubtitle: '来週火曜日、エレベーター点検のお知らせ。',
    authorId: 'author_taitan',
    publishedAt: DateTime(2026, 6, 30),
    thumbnailAsset: _bulletinBanner,
    bodyMarkdown: '''
# エレベーター点検のお知らせ

来週火曜日 10:00〜14:00、エレベーター点検を実施します。

ご不便をおかけします。
''',
  ),
  Content(
    id: 'c015',
    type: ContentType.audio,
    accessLevel: AccessLevel.public,
    title: '団地ラジオ 試聴版',
    description: '冒頭30秒のお試し視聴。',
    authorId: 'author_paon',
    publishedAt: DateTime(2026, 6, 29),
    thumbnailAsset: _banner(6),
    mediaUrl: 'assets/audio/radio_01.mp3',
    bodyMarkdown: '会員登録すると全文視聴できます。',
  ),
  Content(
    id: 'c016',
    type: ContentType.kikikaikai,
    accessLevel: AccessLevel.public,
    title: '奇奇怪怪 #42（前編）',
    description: 'ポッドキャスト「奇奇怪怪」。ポップカルチャーを語る前半。',
    cardSubtitle: 'ポッドキャスト「奇奇怪怪」最新回。',
    authorId: 'author_paon',
    publishedAt: DateTime(2026, 6, 27),
    thumbnailAsset: _kikikaikaiBanner,
    mediaUrl: 'assets/audio/radio_01.mp3',
  ),
  Content(
    id: 'c017',
    type: ContentType.kikikaikai,
    accessLevel: AccessLevel.public,
    title: '奇奇怪怪 #42（後編）',
    description: 'ポッドキャスト「奇奇怪怪」。ポップカルチャーを語る後半。',
    authorId: 'author_paon',
    publishedAt: DateTime(2026, 6, 27),
    thumbnailAsset: _kikikaikaiBanner,
    mediaUrl: 'assets/audio/radio_02.mp3',
  ),
  Content(
    id: 'c018',
    type: ContentType.kikikaikai,
    accessLevel: AccessLevel.public,
    title: '奇奇怪怪 試聴版',
    description: '冒頭30秒のお試し視聴。',
    authorId: 'author_paon',
    publishedAt: DateTime(2026, 6, 26),
    thumbnailAsset: _kikikaikaiBanner,
    mediaUrl: 'assets/audio/radio_02.mp3',
    bodyMarkdown: '会員登録すると全文視聴できます。',
  ),
  // ラジオ追加サンプル（banner 7–11）
  Content(
    id: 'c019',
    type: ContentType.audio,
    accessLevel: AccessLevel.member,
    title: '団地ラジオ #12',
    description: 'エレベーター点検の裏側を語る。',
    authorId: 'author_paon',
    publishedAt: DateTime(2026, 6, 17),
    thumbnailAsset: _banner(7),
    mediaUrl: 'assets/audio/radio_01.mp3',
  ),
  Content(
    id: 'c020',
    type: ContentType.audio,
    accessLevel: AccessLevel.member,
    title: '団地ラジオ #11',
    description: '闇市の夜、団地ラジオ。',
    authorId: 'author_paon',
    publishedAt: DateTime(2026, 6, 16),
    thumbnailAsset: _banner(8),
    mediaUrl: 'assets/audio/radio_02.mp3',
  ),
  Content(
    id: 'c021',
    type: ContentType.audio,
    accessLevel: AccessLevel.member,
    title: '団地ラジオ #10',
    description: 'ゲストとポップカルチャー雑談。',
    authorId: 'author_paon',
    publishedAt: DateTime(2026, 6, 15),
    thumbnailAsset: _banner(9),
    mediaUrl: 'assets/audio/radio_01.mp3',
  ),
  Content(
    id: 'c022',
    type: ContentType.audio,
    accessLevel: AccessLevel.resident,
    title: '団地ラジオ #9',
    description: '団地住民限定の深夜枠。',
    authorId: 'author_paon',
    publishedAt: DateTime(2026, 6, 14),
    thumbnailAsset: _banner(10),
    mediaUrl: 'assets/audio/radio_02.mp3',
  ),
  Content(
    id: 'c023',
    type: ContentType.audio,
    accessLevel: AccessLevel.resident,
    title: '団地ラジオ #8',
    description: '管理室からの臨時放送。',
    authorId: 'author_paon',
    publishedAt: DateTime(2026, 6, 13),
    thumbnailAsset: _banner(11),
    mediaUrl: 'assets/audio/radio_01.mp3',
  ),
  // テレビ追加サンプル（banner 14–19）
  Content(
    id: 'c024',
    type: ContentType.video,
    accessLevel: AccessLevel.member,
    title: '街頭テレビ #6',
    description: '路上インタビュー、渋谷編。',
    cardSubtitle: '街頭テレビ、渋谷の路上から。',
    authorId: 'author_paon',
    publishedAt: DateTime(2026, 6, 11),
    thumbnailAsset: _banner(14),
    mediaUrl: 'assets/video/tv_01.mp4',
  ),
  Content(
    id: 'c025',
    type: ContentType.video,
    accessLevel: AccessLevel.member,
    title: '街頭テレビ #5',
    description: '路上インタビュー、新宿編。',
    authorId: 'author_paon',
    publishedAt: DateTime(2026, 6, 10),
    thumbnailAsset: _banner(15),
    mediaUrl: 'assets/video/tv_02.mp4',
  ),
  Content(
    id: 'c026',
    type: ContentType.video,
    accessLevel: AccessLevel.member,
    title: '街頭テレビ #4',
    description: '路上インタビュー、池袋編。',
    authorId: 'author_paon',
    publishedAt: DateTime(2026, 6, 9),
    thumbnailAsset: _banner(16),
    mediaUrl: 'assets/video/tv_01.mp4',
  ),
  Content(
    id: 'c027',
    type: ContentType.video,
    accessLevel: AccessLevel.resident,
    title: '街頭テレビ #3',
    description: '団地住民限定の未公開カット。',
    authorId: 'author_paon',
    publishedAt: DateTime(2026, 6, 7),
    thumbnailAsset: _banner(17),
    mediaUrl: 'assets/video/tv_02.mp4',
  ),
  Content(
    id: 'c028',
    type: ContentType.video,
    accessLevel: AccessLevel.resident,
    title: '街頭テレビ #2',
    description: '団地住民限定の未公開カット。',
    authorId: 'author_paon',
    publishedAt: DateTime(2026, 6, 6),
    thumbnailAsset: _banner(18),
    mediaUrl: 'assets/video/tv_01.mp4',
  ),
  Content(
    id: 'c029',
    type: ContentType.video,
    accessLevel: AccessLevel.resident,
    title: '街頭テレビ #1',
    description: '団地住民限定の未公開カット。',
    authorId: 'author_paon',
    publishedAt: DateTime(2026, 6, 5),
    thumbnailAsset: _banner(19),
    mediaUrl: 'assets/video/tv_02.mp4',
  ),
];
