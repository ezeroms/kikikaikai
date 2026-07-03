import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_type.dart';
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
  if (content.type.supportsMediaTimestampLinks) {
    return _seedComments(content, _mediaCommentTemplates);
  }
  return _seedComments(content, _textCommentTemplates);
}

const _mediaCommentTemplates = [
  ('団地の住人', 'assets/avatar/paon.png', '01:20 あたりの話が特に刺さりました。'),
  ('深夜ラジオ族', 'assets/avatar/taitan.png', '1:25 付近、もう一度聴き直したい。'),
  ('匿名', 'assets/branding/eye_catch/mypage.png', '1:20:05 の締め、効いてました。'),
  ('品品ファン', 'assets/avatar/tamaoki.png', 'タイムスタンプ 1:20 から聴き直した。'),
];

const _textCommentTemplates = [
  ('団地の住人', 'assets/avatar/paon.png', '面白かったです。また感想を読み返しに来ます。'),
  ('深夜ラジオ族', 'assets/avatar/taitan.png', '途中から読み始めましたが、最後まで一気に読んでしまいました。'),
  ('匿名', 'assets/branding/eye_catch/mypage.png', 'この回、最近の迷いにそのまま刺さりました。'),
  ('品品ファン', 'assets/avatar/tamaoki.png', 'コメント欄初書き込み。これからも楽しみにしています。'),
];

List<DummyCommentSeed> _seedComments(
  Content content,
  List<(String, String, String)> templates,
) {
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
