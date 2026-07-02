import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/features/home/home_feed.dart';
import 'package:kikikaikai/features/home/widgets/home_tab_scroll.dart';
import 'package:kikikaikai/features/home/widgets/featured_carousel_section.dart';
import 'package:kikikaikai/features/home/widgets/home_horizontal_section.dart';

/// 鑑賞画面の「ホーム」タブ — おすすめカルーセルと横スクロールセクション
class HomeMainTab extends ConsumerWidget {
  const HomeMainTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentsAsync = ref.watch(allContentsProvider);

    return contentsAsync.when(
      loading: () => buildHomeMainTabScroll(
        context,
        const [Center(child: CircularProgressIndicator())],
      ),
      error: (error, _) => buildHomeMainTabScroll(
        context,
        [Center(child: Text('読み込みエラー: $error'))],
      ),
      data: (allContents) {
        final recommended = HomeFeed.recommended(allContents);

        return buildHomeMainTabScroll(
          context,
          [
            const SizedBox(height: 8),
            FeaturedCarouselSection(contents: recommended),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ...HomeFeed.sections.expand((section) {
                    final items = section.items(allContents);
                    if (items.isEmpty) return <Widget>[];
                    return [
                      HomeHorizontalSection(
                        title: section.title,
                        contents: items,
                      ),
                      const SizedBox(height: 32),
                    ];
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
