import 'package:kikikaikai/core/models/access_level.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_type.dart';

const _kairanban = 'assets/branding/eye_catch/kairanban.png';
const _gaitoradio = 'assets/branding/eye_catch/gaitoradio.png';
const _gaitotv = 'assets/branding/eye_catch/gaitotv.png';
const _gyokko = 'assets/branding/eye_catch/gyokko.png';
const _ogp = 'assets/branding/ogp_common.png';
const _bgHome = 'assets/branding/bg_home_mobile.png';

final dummyContents = <Content>[
  Content(
    id: 'c001',
    type: ContentType.bulletin,
    accessLevel: AccessLevel.public,
    title: 'PINPIN MART 復活',
    description: '闇市の品品団地、小売部門が復活した。',
    authorId: 'author_kanri',
    publishedAt: DateTime(2026, 6, 28),
    thumbnailAsset: _ogp,
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
    authorId: 'author_kanri',
    publishedAt: DateTime(2026, 6, 25),
    thumbnailAsset: _kairanban,
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
    authorId: 'author_kanri',
    publishedAt: DateTime(2026, 6, 20),
    thumbnailAsset: _bgHome,
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
    authorId: 'author_taitan',
    publishedAt: DateTime(2026, 6, 22),
    thumbnailAsset: _gaitoradio,
    mediaUrl: 'assets/audio/radio_01.mp3',
  ),
  Content(
    id: 'c005',
    type: ContentType.audio,
    accessLevel: AccessLevel.resident,
    title: 'ポップカルチャーと団地（後編）',
    description: '団地住民限定。同じ回の後半パート。',
    authorId: 'author_taitan',
    publishedAt: DateTime(2026, 6, 22),
    thumbnailAsset: _gaitoradio,
    mediaUrl: 'assets/audio/radio_02.mp3',
  ),
  Content(
    id: 'c006',
    type: ContentType.video,
    accessLevel: AccessLevel.member,
    title: '街頭インタビュー #7（前半）',
    description: '街頭テレビ、路上からの配信。前半は無料会員まで。',
    authorId: 'author_guest',
    publishedAt: DateTime(2026, 6, 18),
    thumbnailAsset: _gaitotv,
    mediaUrl: 'assets/video/tv_01.mp4',
  ),
  Content(
    id: 'c007',
    type: ContentType.video,
    accessLevel: AccessLevel.resident,
    title: '街頭インタビュー #7（後半）',
    description: '団地住民限定。同じ回の後半パート。',
    authorId: 'author_guest',
    publishedAt: DateTime(2026, 6, 18),
    thumbnailAsset: _gaitotv,
    mediaUrl: 'assets/video/tv_02.mp4',
  ),
  Content(
    id: 'c008',
    type: ContentType.manuscript,
    accessLevel: AccessLevel.member,
    title: '都市伝説の系譜学',
    description: '玉置玉稿、エッセイ連載。',
    authorId: 'author_tamaki',
    publishedAt: DateTime(2026, 6, 12),
    thumbnailAsset: _gyokko,
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
    thumbnailAsset: _gyokko,
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
    authorId: 'author_taitan',
    publishedAt: DateTime(2025, 12, 31),
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
    authorId: 'author_kanri',
    publishedAt: DateTime(2026, 6, 30),
    thumbnailAsset: _kairanban,
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
    authorId: 'author_taitan',
    publishedAt: DateTime(2026, 6, 29),
    thumbnailAsset: _gaitoradio,
    mediaUrl: 'assets/audio/radio_01.mp3',
    bodyMarkdown: '会員登録すると全文視聴できます。',
  ),
];
