import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/features/content/widgets/content_detail_nested_tab_scroll.dart';

const _fallbackTranscript = '''
TaiTan：書き起こしデータは準備中です。

玉置：本編を聴きながら、メモを取るのもいい。言葉は後からついてくる。

TaiTan：公開までしばらくお待ちください。
''';

class AudioDetailTranscriptTab extends StatelessWidget {
  const AudioDetailTranscriptTab({super.key, required this.content});

  final Content content;

  @override
  Widget build(BuildContext context) {
    final text = content.transcript?.trim().isNotEmpty == true
        ? content.transcript!.trim()
        : _fallbackTranscript.trim();

    return Builder(
      builder: (context) => buildContentDetailNestedScroll(
        context,
        child: Text(
          text,
          style: AppTypography.body(size: 15).copyWith(height: 1.7),
        ),
      ),
    );
  }
}
