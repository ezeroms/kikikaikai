import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/core/media/media_timestamp.dart';
import 'package:kikikaikai/core/media/media_timestamp_seek.dart';
import 'package:kikikaikai/core/models/content.dart';

/// プレーンテキスト内の `1:20` / `1:20:05` などをタップ可能なシークリンクにする。
class TimestampLinkText extends StatefulWidget {
  const TimestampLinkText({
    super.key,
    required this.text,
    required this.style,
    this.content,
    this.previewLimit,
  });

  final String text;
  final TextStyle style;
  final Content? content;
  final Duration? previewLimit;

  static TextStyle linkStyle(TextStyle base) => base.copyWith(
        color: AppColors.onBase,
        fontWeight: FontWeight.w700,
      );

  @override
  State<TimestampLinkText> createState() => _TimestampLinkTextState();
}

class _TimestampLinkTextState extends State<TimestampLinkText> {
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
    final seekEnabled =
        content != null && MediaTimestampSeek.isSupported(content);

    if (!seekEnabled || !MediaTimestamp.hasMatch(widget.text)) {
      return Text(widget.text, style: widget.style);
    }

    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();

    final spans = <InlineSpan>[];
    var lastEnd = 0;
    for (final match in MediaTimestamp.pattern.allMatches(widget.text)) {
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: widget.text.substring(lastEnd, match.start),
            style: widget.style,
          ),
        );
      }

      final raw = match.group(1)!;
      final duration = MediaTimestamp.parse(raw);
      if (duration != null) {
        final recognizer = TapGestureRecognizer()
          ..onTap = () {
            MediaTimestampSeek.seek(
              content,
              duration,
              previewLimit: widget.previewLimit,
            );
          };
        _recognizers.add(recognizer);
        spans.add(
          TextSpan(
            text: raw,
            style: TimestampLinkText.linkStyle(widget.style),
            recognizer: recognizer,
          ),
        );
      } else {
        spans.add(TextSpan(text: raw, style: widget.style));
      }
      lastEnd = match.end;
    }

    if (lastEnd < widget.text.length) {
      spans.add(
        TextSpan(
          text: widget.text.substring(lastEnd),
          style: widget.style,
        ),
      );
    }

    return Text.rich(TextSpan(children: spans));
  }
}
