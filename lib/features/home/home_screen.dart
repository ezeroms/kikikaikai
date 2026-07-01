import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/features/home/home_feed.dart';
import 'package:kikikaikai/features/home/widgets/featured_carousel_section.dart';
import 'package:kikikaikai/features/home/widgets/home_horizontal_section.dart';
import 'package:kikikaikai/features/home/browse_tab.dart';
import 'package:kikikaikai/features/home/widgets/browse_pill_tab_bar.dart';
import 'package:kikikaikai/shared/widgets/content_card.dart';
import 'package:kikikaikai/shared/widgets/mini_player_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: BrowseTab.values.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        toolbarHeight: 96,
        title: Image.asset(
          'assets/branding/pinpin/logo.png',
          height: 80,
          fit: BoxFit.contain,
        ),
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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BrowsePillTabBar(controller: _tabController),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: BrowseTab.values.map((tab) {
                if (tab == BrowseTab.home) {
                  return const _BrowseHomeTab();
                }
                return _BrowseCategoryTab(type: tab.contentType!);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrowseHomeTab extends ConsumerWidget {
  const _BrowseHomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentsAsync = ref.watch(allContentsProvider);

    return contentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('読み込みエラー: $e')),
      data: (all) {
        final recommended = HomeFeed.recommended(all);

        return ListView(
          padding: EdgeInsets.fromLTRB(
            0,
            8,
            0,
            32 + miniPlayerScrollPadding(context),
          ),
          children: [
            FeaturedCarouselSection(contents: recommended),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ...HomeFeed.sections.expand((section) {
                    final items = section.items(all);
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
            8,
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
