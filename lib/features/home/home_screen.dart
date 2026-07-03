import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/features/home/home_tab.dart';
import 'package:kikikaikai/features/home/widgets/home_category_tab.dart';
import 'package:kikikaikai/features/home/widgets/home_main_tab.dart';
import 'package:kikikaikai/features/home/widgets/home_category_tab_scroll_scope.dart';
import 'package:kikikaikai/features/home/widgets/home_logo_header_sliver.dart';
import 'package:kikikaikai/features/home/widgets/home_pill_tab_bar.dart';
import 'package:kikikaikai/features/home/widgets/home_tab_bar_sliver.dart';

/// 鑑賞画面（下部ナビのホーム相当）。ロゴ・横タブ・各カテゴリの一覧を表示する。
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _nestedScrollController = ScrollController();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: HomeTab.values.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _nestedScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base,
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          controller: _nestedScrollController,
          clipBehavior: Clip.hardEdge,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: const SliverToBoxAdapter(
                  child: HomeLogoHeader(),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: HomeTabBarSliver(
                  child: HomePillTabBar(controller: _tabController),
                ),
              ),
            ];
          },
          body: HomeCategoryTabScrollScope(
            outerScrollController: _nestedScrollController,
            child: TabBarView(
              controller: _tabController,
              children: [
                for (final tab in HomeTab.values)
                  tab == HomeTab.home
                      ? const HomeMainTab()
                      : HomeCategoryTab(tab: tab),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
