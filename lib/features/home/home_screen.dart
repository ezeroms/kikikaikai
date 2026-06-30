import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/shared/widgets/content_card.dart';
import 'package:kikikaikai/shared/widgets/mini_player_bar.dart';

enum BrowseTab {
  home,
  bulletin,
  radio,
  tv,
  manuscript;

  String get label => switch (this) {
        BrowseTab.home => 'ホーム',
        BrowseTab.bulletin => '回覧板',
        BrowseTab.radio => 'ラジオ',
        BrowseTab.tv => 'テレビ',
        BrowseTab.manuscript => '玉稿',
      };

  ContentType? get contentType => switch (this) {
        BrowseTab.home => null,
        BrowseTab.bulletin => ContentType.bulletin,
        BrowseTab.radio => ContentType.audio,
        BrowseTab.tv => ContentType.video,
        BrowseTab.manuscript => ContentType.manuscript,
      };
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: BrowseTab.values.length,
      child: Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          title: Text('鑑賞', style: AppTypography.heading(size: 18)),
          actions: [
            IconButton(
              onPressed: () => context.push('/mypage'),
              icon: const Icon(
                LucideIcons.user,
                color: AppColors.summerWood,
              ),
              tooltip: '自室',
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.mangoTango,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.shuttleGray,
            labelStyle: AppTypography.label(size: 14),
            unselectedLabelStyle: AppTypography.label(size: 14),
            dividerColor: AppColors.riverRoad.withValues(alpha: 0.3),
            tabs: BrowseTab.values
                .map((tab) => Tab(text: tab.label))
                .toList(),
          ),
        ),
        body: TabBarView(
          children: BrowseTab.values.map((tab) {
            if (tab == BrowseTab.home) {
              return const _BrowseHomeTab();
            }
            return _BrowseCategoryTab(type: tab.contentType!);
          }).toList(),
        ),
      ),
    );
  }
}

class _BrowseHomeTab extends ConsumerWidget {
  const _BrowseHomeTab();

  static const _featuredTypes = {
    ContentType.bulletin,
    ContentType.audio,
    ContentType.video,
    ContentType.manuscript,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentsAsync = ref.watch(allContentsProvider);

    return contentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('読み込みエラー: $e')),
      data: (all) {
        final featured = all
            .where((c) => _featuredTypes.contains(c.type))
            .toList()
          ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

        final trending = featured.take(5).toList();
        final latest = featured;

        return ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            32 + miniPlayerScrollPadding(context),
          ),
          children: [
            Text('トレンド', style: AppTypography.heading(size: 18)),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: trending.length,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  return ContentCard(
                    content: trending[index],
                    width: 280,
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Text('新着', style: AppTypography.heading(size: 18)),
            const SizedBox(height: 12),
            ...latest.map(
              (content) => Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ContentCard(content: content),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BrowseCategoryTab extends ConsumerWidget {
  const _BrowseCategoryTab({required this.type});

  final ContentType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentsAsync = ref.watch(contentsByTypeProvider(type));

    return contentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('読み込みエラー: $e')),
      data: (contents) {
        if (contents.isEmpty) {
          return Center(
            child: Text(
              'コンテンツがありません',
              style: AppTypography.body(color: AppColors.shuttleGray),
            ),
          );
        }

        final sorted = [...contents]
          ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            32 + miniPlayerScrollPadding(context),
          ),
          itemCount: sorted.length,
          separatorBuilder: (_, _) => const SizedBox(height: 24),
          itemBuilder: (context, index) {
            return ContentCard(content: sorted[index]);
          },
        );
      },
    );
  }
}
