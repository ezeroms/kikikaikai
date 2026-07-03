/// ラジオコンテンツのメディア形式（音声のみ / 映像付き）
enum ContentMediaFormat {
  audioOnly,
  audioWithVideo;

  bool get isVideo => this == ContentMediaFormat.audioWithVideo;
}
