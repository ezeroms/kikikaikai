/// 回覧板・玉稿本文の Markdown を表示用に正規化する。
///
/// CMS 由来のテキストは「・」で箇条書き風に書かれるが、Markdown のリスト
/// （`-` / `*` / `+` / 番号付き）として解釈させない。
abstract final class BodyMarkdownNormalizer {
  static String normalize(String data) {
    final lines = data.split('\n');
    final result = <String>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.trim().isEmpty) {
        final previous = _lastNonEmpty(result);
        final next = _nextNonEmpty(lines, i + 1);
        if (_startsWithMiddleDot(previous) && _startsWithMiddleDot(next)) {
          continue;
        }
        result.add(line);
        continue;
      }

      result.add(_escapeListMarker(line));
    }

    return result.join('\n');
  }

  static String? _lastNonEmpty(List<String> lines) {
    for (var i = lines.length - 1; i >= 0; i--) {
      if (lines[i].trim().isNotEmpty) {
        return lines[i];
      }
    }
    return null;
  }

  static String? _nextNonEmpty(List<String> lines, int start) {
    for (var i = start; i < lines.length; i++) {
      if (lines[i].trim().isNotEmpty) {
        return lines[i];
      }
    }
    return null;
  }

  static bool _startsWithMiddleDot(String? line) {
    if (line == null) {
      return false;
    }
    return line.trimLeft().startsWith('・');
  }

  static String _escapeListMarker(String line) {
    final unordered = RegExp(r'^(\s*)([-+*])( +)(.*)$').firstMatch(line);
    if (unordered != null) {
      return '${unordered.group(1)}\\${unordered.group(2)}'
          '${unordered.group(3)}${unordered.group(4)}';
    }

    final ordered = RegExp(r'^(\s*)(\d{1,9})([.)])( +)(.*)$').firstMatch(line);
    if (ordered != null) {
      return '${ordered.group(1)}\\${ordered.group(2)}${ordered.group(3)}'
          '${ordered.group(4)}${ordered.group(5)}';
    }

    return line;
  }
}
