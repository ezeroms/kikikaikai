/// YouTube 概要欄・コメント欄と同様の `M:SS` / `H:MM:SS` タイムスタンプ。
abstract final class MediaTimestamp {
  MediaTimestamp._();

  static const linkScheme = 'media-seek://';

  /// 行頭・空白・開き括弧の直後、空白・閉じ括弧・句読点・行末の直前に現れる形式。
  static final pattern = RegExp(
    r'(?<=^|[\s(\[])((?:\d{1,2}:)?\d{1,2}:\d{2})(?=$|[\s)\].,!?:;])',
    multiLine: true,
  );

  static bool hasMatch(String text) => pattern.hasMatch(text);

  static Duration? parse(String text) {
    final parts = text.split(':');
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]);
      final seconds = int.tryParse(parts[1]);
      if (minutes == null || seconds == null) return null;
      if (seconds < 0 || seconds > 59) return null;
      return Duration(minutes: minutes, seconds: seconds);
    }
    if (parts.length == 3) {
      final hours = int.tryParse(parts[0]);
      final minutes = int.tryParse(parts[1]);
      final seconds = int.tryParse(parts[2]);
      if (hours == null || minutes == null || seconds == null) return null;
      if (minutes < 0 || minutes > 59 || seconds < 0 || seconds > 59) return null;
      return Duration(hours: hours, minutes: minutes, seconds: seconds);
    }
    return null;
  }

  static String linkHref(Duration position) =>
      '$linkScheme${position.inSeconds}';

  static Duration? durationFromHref(String? href) {
    if (href == null || !href.startsWith(linkScheme)) return null;
    final seconds = int.tryParse(href.substring(linkScheme.length));
    if (seconds == null || seconds < 0) return null;
    return Duration(seconds: seconds);
  }

  /// Markdown 本文内のタイムスタンプを `[1:20](media-seek://80)` 形式へ変換する。
  static String linkifyMarkdown(String text) {
    return text.replaceAllMapped(pattern, (match) {
      final raw = match.group(1)!;
      final duration = parse(raw);
      if (duration == null) return match.group(0)!;
      return '[$raw](${linkHref(duration)})';
    });
  }
}
