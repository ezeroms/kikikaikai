import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/data/dummy/dummy_contents.dart';

/// シード用コメント（SQLite `content_comments` に投入）
class DummyCommentSeed {
  const DummyCommentSeed({
    required this.id,
    required this.contentId,
    required this.authorName,
    required this.body,
    required this.createdAt,
    this.authorAvatarAsset,
  });

  final String id;
  final String contentId;
  final String authorName;
  final String body;
  final DateTime createdAt;
  final String? authorAvatarAsset;
}

final dummyCommentSeeds = [
  for (final content in dummyContents)
    if (content.type.usesTabbedDetail) ..._commentsFor(content),
];

List<DummyCommentSeed> _commentsFor(Content content) {
  const templates = [
    ('団地の住人', 'assets/avatar/paon.png', '面白かったです。また感想を読み返しに来ます。'),
    ('深夜ラジオ族', 'assets/avatar/taitan.png', '途中から聴き始めましたが、最後まで一気に聴いてしまいました。'),
    ('匿名', 'assets/branding/eye_catch/mypage.png', 'この回、最近の迷いにそのまま刺さりました。'),
    ('品品ファン', 'assets/avatar/tamaoki.png', 'コメント欄初書き込み。これからも楽しみにしています。'),
  ];

  return [
    for (var i = 0; i < templates.length; i++)
      DummyCommentSeed(
        id: 'seed_${content.id}_$i',
        contentId: content.id,
        authorName: templates[i].$1,
        authorAvatarAsset: templates[i].$2,
        body: templates[i].$3,
        createdAt: content.publishedAt.add(Duration(hours: 8 + i * 5)),
      ),
  ];
}
