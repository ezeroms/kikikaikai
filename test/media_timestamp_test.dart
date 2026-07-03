import 'package:flutter_test/flutter_test.dart';
import 'package:kikikaikai/core/media/media_timestamp.dart';

void main() {
  group('MediaTimestamp.parse', () {
    test('parses MM:SS with optional leading zero', () {
      expect(MediaTimestamp.parse('01:20'), const Duration(minutes: 1, seconds: 20));
      expect(MediaTimestamp.parse('1:20'), const Duration(minutes: 1, seconds: 20));
      expect(MediaTimestamp.parse('1:25'), const Duration(minutes: 1, seconds: 25));
    });

    test('parses H:MM:SS', () {
      expect(
        MediaTimestamp.parse('1:20:05'),
        const Duration(hours: 1, minutes: 20, seconds: 5),
      );
      expect(
        MediaTimestamp.parse('00:00:00'),
        Duration.zero,
      );
    });

    test('rejects invalid seconds', () {
      expect(MediaTimestamp.parse('1:99'), isNull);
    });
  });

  group('MediaTimestamp.linkifyMarkdown', () {
    test('wraps timestamps in media-seek links', () {
      const input = '00:00 冒頭\n\n01:20 本題';
      expect(
        MediaTimestamp.linkifyMarkdown(input),
        '[00:00](media-seek://0) 冒頭\n\n[01:20](media-seek://80) 本題',
      );
    });
  });

  group('MediaTimestamp.pattern', () {
    test('does not match digits inside version-like strings', () {
      expect(MediaTimestamp.pattern.allMatches('v2:30:45'), isEmpty);
    });
  });
}
