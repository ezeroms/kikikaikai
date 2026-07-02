import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/models/content.dart';

const _dummyTranscript = '''
司会：今日は「働くよりも旅に出よう」をテーマにお話しします。

TaiTan：最近、仕事のことばかり考えていて、自分の言葉が見つからない感覚があるんです。

玉置：わかります。情報を消費するだけでは、自分の中に言葉が残らない。だからこそ、旅に出るというのは、言葉を取り戻すための行為なのかもしれません。

司会：旅に出るとは、物理的に移動することだけではないですよね。

TaiTan：そうですね。日常のリズムから外れることで、初めて聞こえてくる音がある。電車の中で隣の人の会話を聞いたり、知らない街の空気を吸ったり。

玉置：それは観光ではなく、ただそこにいることなんですよね。観察するというより、ただ在る。

司会：なるほど。では、最近旅に出たと感じた瞬間はありますか。

TaiTan：先週、急に雨が降って、傘をささずに歩いたときです。濡れた靴の感覚が、なぜかすごく鮮明で。

玉置：それはいいですね。身体が先に記憶する。言葉はあとからついてくる。

司会：今日の話をまとめると、旅は逃避ではなく、自分の言葉を取り戻すための実践なのかもしれませんね。

TaiTan：そう言われると、明日からの通勤も少し違って見えてきます。

玉置：通勤も旅の一部です。同じ路線でも、毎日違う空が見えることはありますから。

司会：ありがとうございました。
''';

class AudioDetailTranscriptTab extends StatelessWidget {
  const AudioDetailTranscriptTab({super.key, required this.content});

  final Content content;

  @override
  Widget build(BuildContext context) {
    final text = content.bodyMarkdown?.trim().isNotEmpty == true
        ? _stripMarkdown(content.bodyMarkdown!)
        : _dummyTranscript.trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Text(
        text,
        style: AppTypography.body(size: 15).copyWith(height: 1.7),
      ),
    );
  }

  String _stripMarkdown(String markdown) {
    return markdown
        .replaceAll(RegExp(r'^#+\s*', multiLine: true), '')
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1')
        .replaceAll('**', '')
        .replaceAll('*', '')
        .trim();
  }
}
