import 'package:kikikaikai/core/models/author.dart';

final dummyAuthors = <Author>[
  const Author(
    id: 'author_taitan',
    name: 'タイタン',
    bio: '団地ラジオの進行。今話したい人を呼んで適切な雑談をする。',
    avatarAsset: 'assets/branding/eye_catch/gaitoradio.png',
  ),
  const Author(
    id: 'author_tamaki',
    name: '玉置',
    bio: '玉置玉稿の執筆者。夜の便所詩を書く。',
    avatarAsset: 'assets/branding/eye_catch/gyokko.png',
  ),
  const Author(
    id: 'author_kanri',
    name: '団地管理室',
    bio: '回覧板の更新担当。エレベーター点検のお知らせを書く。',
    avatarAsset: 'assets/branding/eye_catch/kairanban.png',
  ),
  const Author(
    id: 'author_guest',
    name: 'ゲスト',
    bio: '団地なのでジャンルレスで面白い人が集まる。',
    avatarAsset: 'assets/branding/eye_catch/mypage.png',
  ),
];
