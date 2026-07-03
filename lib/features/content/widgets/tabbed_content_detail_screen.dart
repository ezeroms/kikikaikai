import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/debug/playback_debug_log.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/core/models/user_tier.dart';
import 'package:kikikaikai/core/media/media_playback.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/features/content/widgets/audio_detail_comments_tab.dart';
import 'package:kikikaikai/features/content/widgets/audio_detail_player_header.dart';
import 'package:kikikaikai/features/content/widgets/audio_detail_transcript_tab.dart';
import 'package:kikikaikai/features/content/widgets/content_detail_main_tab.dart';
import 'package:kikikaikai/features/content/widgets/content_detail_nested_tab_scroll.dart';
import 'package:kikikaikai/features/content/widgets/content_detail_tab_bar_sliver.dart';
import 'package:kikikaikai/features/content/widgets/kikikaikai_detail_background.dart';
import 'package:kikikaikai/features/content/widgets/text_article_detail_header.dart';
import 'package:kikikaikai/features/content/widgets/video_detail_header.dart';
import 'package:kikikaikai/shared/widgets/access_lock_overlay.dart';

class TabbedContentDetailScreen extends ConsumerStatefulWidget {
  const TabbedContentDetailScreen({
    super.key,
    required this.content,
    required this.userTier,
    required this.canAccess,
    required this.previewOnly,
    required this.isDownloaded,
  });

  final Content content;
  final UserTier userTier;
  final bool canAccess;
  final bool previewOnly;
  final bool isDownloaded;

  @override
  ConsumerState<TabbedContentDetailScreen> createState() =>
      _TabbedContentDetailScreenState();
}

class _TabbedContentDetailScreenState
    extends ConsumerState<TabbedContentDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _nestedScrollKey = GlobalKey<NestedScrollViewState>();
  final _playerHeaderKey = GlobalKey();
  final _textArticleHeaderKey = GlobalKey();
  final _videoHeaderKey = GlobalKey();
  VoidCallback? _onPlaybackSessionChanged;
  bool _visibilityUpdateScheduled = false;
  bool _scrollHeaderAppBarTitleVisible = false;

  bool get _hasTranscriptTab => widget.content.hasTranscriptTab;

  bool get _showAudioPlayer =>
      widget.content.usesAudioDetailLayout &&
      widget.content.mediaUrl != null &&
      (widget.canAccess || widget.previewOnly);

  bool get _showVideoPlayer =>
      widget.content.usesVideoDetailLayout &&
      widget.content.mediaUrl != null &&
      (widget.canAccess || widget.previewOnly);

  bool get _showScrollAwayMiniPlayer => _showAudioPlayer || _showVideoPlayer;

  bool get _usesScrollAwayHeaderAppBarTitle =>
      widget.content.type.isTextArticle ||
      widget.content.usesVideoDetailLayout ||
      widget.content.usesAudioDetailLayout;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _hasTranscriptTab ? 3 : 2,
      vsync: this,
    );

    if (widget.content.type.isTextArticle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(contentEngagementProvider.notifier)
            .markViewed(widget.content.id);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(detailScreenContentIdProvider.notifier).state =
          widget.content.id;
      _attachScrollListeners();
      _attachPlaybackListeners();
      _updateMiniPlayerVisibility();
      _updateScrollHeaderAppBarTitle();
    });
  }

  void _attachPlaybackListeners() {
    final handler = MediaPlayback.handler;
    if (handler == null) return;

    if (_onPlaybackSessionChanged != null) {
      handler.sessionActiveNotifier
          .removeListener(_onPlaybackSessionChanged!);
      handler.currentContentNotifier.removeListener(_onPlaybackSessionChanged!);
    }

    _onPlaybackSessionChanged = () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateMiniPlayerVisibility();
      });
    };

    handler.sessionActiveNotifier.addListener(_onPlaybackSessionChanged!);
    handler.currentContentNotifier.addListener(_onPlaybackSessionChanged!);
  }

  void _attachScrollListeners() {
    final nestedScroll = _nestedScrollKey.currentState;
    if (nestedScroll == null) return;

    nestedScroll.outerController.removeListener(_onOuterScroll);
    nestedScroll.outerController.addListener(_onOuterScroll);
  }

  void _onOuterScroll() {
    _updateMiniPlayerVisibility();
    _updateScrollHeaderAppBarTitle();
  }

  void _writeDetailMiniPlayerVisible(bool visible) {
    if (ref.read(detailMiniPlayerVisibleProvider) != visible) {
      ref.read(detailMiniPlayerVisibleProvider.notifier).state = visible;
    }
  }

  void _clearDetailProviders() {
    final miniPlayer = ref.read(detailMiniPlayerVisibleProvider.notifier);
    final detailId = ref.read(detailScreenContentIdProvider.notifier);
    Future.microtask(() {
      miniPlayer.state = false;
      detailId.state = null;
    });
  }

  @override
  void deactivate() {
    _clearDetailProviders();
    super.deactivate();
  }

  @override
  void dispose() {
    final nestedScroll = _nestedScrollKey.currentState;
    nestedScroll?.outerController.removeListener(_onOuterScroll);
    final handler = MediaPlayback.handler;
    if (handler != null && _onPlaybackSessionChanged != null) {
      handler.sessionActiveNotifier.removeListener(_onPlaybackSessionChanged!);
      handler.currentContentNotifier.removeListener(_onPlaybackSessionChanged!);
    }
    _tabController.dispose();
    super.dispose();
  }

  bool _isScrollHeaderFullyHidden() {
    final nestedScroll = _nestedScrollKey.currentState;
    if (nestedScroll != null) {
      final outer = nestedScroll.outerController;
      if (outer.hasClients) {
        final pixels = outer.position.pixels;
        if (pixels <= 1.0) {
          return false;
        }
        final maxExtent = outer.position.maxScrollExtent;
        if (maxExtent > 0 && pixels >= maxExtent - 1.0) {
          return true;
        }
      }
    }

    final headerContext = _scrollHeaderKey.currentContext;
    final nestedContext = _nestedScrollKey.currentContext;
    if (headerContext == null || nestedContext == null) return false;

    final headerBox = headerContext.findRenderObject() as RenderBox?;
    final nestedBox = nestedContext.findRenderObject() as RenderBox?;
    if (headerBox == null ||
        nestedBox == null ||
        !headerBox.hasSize ||
        !nestedBox.hasSize) {
      return false;
    }

    final headerBottom =
        headerBox.localToGlobal(Offset.zero).dy + headerBox.size.height;
    final viewportTop = nestedBox.localToGlobal(Offset.zero).dy;

    return headerBottom <= viewportTop + 0.5;
  }

  GlobalKey get _scrollHeaderKey {
    if (widget.content.type.isTextArticle) return _textArticleHeaderKey;
    if (widget.content.usesVideoDetailLayout) return _videoHeaderKey;
    if (widget.content.usesAudioDetailLayout) return _playerHeaderKey;
    return _textArticleHeaderKey;
  }

  void _updateScrollHeaderAppBarTitle() {
    if (!_usesScrollAwayHeaderAppBarTitle) return;

    final visible = _isScrollHeaderFullyHidden();
    if (visible == _scrollHeaderAppBarTitleVisible) return;

    setState(() => _scrollHeaderAppBarTitleVisible = visible);
  }

  void _updateMiniPlayerVisibility() {
    if (!mounted || _visibilityUpdateScheduled) return;

    _visibilityUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _visibilityUpdateScheduled = false;
      if (!mounted) return;
      _applyMiniPlayerVisibility();
    });
  }

  void _applyMiniPlayerVisibility() {
    if (!_showScrollAwayMiniPlayer) {
      PlaybackDebugLog.log(
        'DetailMiniPlayer',
        'hide content=${widget.content.id} reason=no-media-player',
      );
      _writeDetailMiniPlayerVisible(false);
      return;
    }

    final nestedScroll = _nestedScrollKey.currentState;
    final outer = nestedScroll?.outerController;
    final hasOuter = outer?.hasClients ?? false;
    final pixels = hasOuter ? outer!.position.pixels : null;
    final maxExtent = hasOuter ? outer!.position.maxScrollExtent : null;
    final headerHidden = _isScrollHeaderFullyHidden();
    final providerBefore = ref.read(detailMiniPlayerVisibleProvider);

    PlaybackDebugLog.log(
      'DetailMiniPlayer',
      'update content=${widget.content.id} pixels=$pixels maxExtent=$maxExtent '
      'headerHidden=$headerHidden providerBefore=$providerBefore',
    );

    _writeDetailMiniPlayerVisible(headerHidden);

    final providerAfter = ref.read(detailMiniPlayerVisibleProvider);
    if (providerAfter != providerBefore) {
      PlaybackDebugLog.log(
        'DetailMiniPlayer',
        'provider changed content=${widget.content.id} '
        '$providerBefore -> $providerAfter',
      );
    }
  }

  TabBar _buildTabBar() {
    return TabBar(
      controller: _tabController,
      dividerColor: AppColors.onBase.withValues(alpha: 0.15),
      dividerHeight: 1,
      indicatorColor: AppColors.onBase,
      indicatorWeight: 3,
      labelColor: AppColors.onBase,
      unselectedLabelColor: AppColors.muted,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      tabs: [
        Tab(text: widget.content.type.isTextArticle ? '本文' : '概要'),
        if (_hasTranscriptTab) const Tab(text: '書き起こし'),
        const Tab(text: 'コメント'),
      ],
    );
  }

  Widget _buildAppBarTitle({
    required bool usesScrollAwayHeaderAppBarTitle,
  }) {
    if (usesScrollAwayHeaderAppBarTitle && !_scrollHeaderAppBarTitleVisible) {
      return const SizedBox.shrink();
    }

    if (usesScrollAwayHeaderAppBarTitle) {
      return Text(
        widget.content.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: AppTypography.titleSmall(size: 16),
      );
    }

    return Text(widget.content.type.label);
  }

  @override
  Widget build(BuildContext context) {
    final showAudioPlayer = _showAudioPlayer;
    final showVideoPlayer = _showVideoPlayer;
    final isTextArticle = widget.content.type.isTextArticle;
    final usesVideoDetailLayout = widget.content.usesVideoDetailLayout;
    final usesScrollAwayHeaderAppBarTitle = _usesScrollAwayHeaderAppBarTitle;
    final tabBar = _buildTabBar();
    final detailBackgroundAsset = widget.content.type.detailBackgroundAsset;
    final hasDetailBackgroundImage = detailBackgroundAsset != null;
    final hasSolidBlackDetailBackground =
        widget.content.type == ContentType.audio;
    final hasImmersiveDetailBackground =
        hasDetailBackgroundImage ||
        widget.content.type == ContentType.audio;
    final detailScaffoldColor = usesVideoDetailLayout
        ? Colors.black
        : (hasImmersiveDetailBackground
            ? Colors.transparent
            : AppColors.base);
    final detailChromeBackgroundColor =
        hasImmersiveDetailBackground ? Colors.transparent : AppColors.base;
    final tabBarHeight = tabBar.preferredSize.height;

    return Stack(
      children: [
        if (hasDetailBackgroundImage)
          Positioned.fill(
            child: IgnorePointer(
              child: CategoryDetailBackground(
                imageAsset: detailBackgroundAsset,
              ),
            ),
          ),
        if (hasSolidBlackDetailBackground)
          const Positioned.fill(
            child: ColoredBox(color: Colors.black),
          ),
        Scaffold(
          backgroundColor: detailScaffoldColor,
          appBar: AppBar(
            centerTitle: usesScrollAwayHeaderAppBarTitle,
            title: _buildAppBarTitle(
              usesScrollAwayHeaderAppBarTitle: usesScrollAwayHeaderAppBarTitle,
            ),
            backgroundColor: detailChromeBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            actions: [
              IconButton(
                onPressed: () async {
                  await ref
                      .read(downloadIdsProvider.notifier)
                      .toggleDownload(widget.content.id);
                },
                icon: Icon(
                  widget.isDownloaded
                      ? LucideIcons.circle_check
                      : LucideIcons.download,
                  color: AppColors.onBase,
                ),
                tooltip: widget.isDownloaded ? 'ダウンロード済み' : 'ダウンロード',
              ),
            ],
          ),
          body: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  _onOuterScroll();
                  return false;
                },
                child: ContentDetailTabScrollScope(
                  clipsBodyBelowTabBar: true,
                  child: NestedScrollView(
                    key: _nestedScrollKey,
                    clipBehavior: Clip.hardEdge,
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        if (showAudioPlayer)
                          SliverToBoxAdapter(
                            child: KeyedSubtree(
                              key: _playerHeaderKey,
                              child: AudioDetailPlayerHeader(
                                key: ValueKey(widget.content.id),
                                content: widget.content,
                                previewLimit: widget.previewOnly
                                    ? const Duration(seconds: 30)
                                    : null,
                              ),
                            ),
                          ),
                        if (isTextArticle)
                          SliverToBoxAdapter(
                            child: KeyedSubtree(
                              key: _textArticleHeaderKey,
                              child: TextArticleDetailHeader(
                                content: widget.content,
                              ),
                            ),
                          ),
                        if (usesVideoDetailLayout)
                          SliverToBoxAdapter(
                            child: KeyedSubtree(
                              key: _videoHeaderKey,
                              child: VideoDetailHeader(
                                content: widget.content,
                                canAccess: widget.canAccess,
                                previewOnly: widget.previewOnly,
                                showVideoPlayer: showVideoPlayer,
                              ),
                            ),
                          ),
                        SliverOverlapAbsorber(
                          handle:
                              NestedScrollView.sliverOverlapAbsorberHandleFor(
                            context,
                          ),
                          sliver: SliverPersistentHeader(
                            pinned: true,
                            delegate: ContentDetailTabBarSliver(
                              tabBar: tabBar,
                              backgroundColor: detailChromeBackgroundColor,
                            ),
                          ),
                        ),
                      ];
                    },
                    body: ClipRect(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned.fill(
                            top: tabBarHeight,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                ContentDetailMainTab(
                                  content: widget.content,
                                  canAccess: widget.canAccess,
                                  previewOnly: widget.previewOnly,
                                ),
                                if (_hasTranscriptTab)
                                  AudioDetailTranscriptTab(
                                    content: widget.content,
                                  ),
                                AudioDetailCommentsTab(
                                  content: widget.content,
                                  previewLimit: widget.previewOnly
                                      ? widget.content.previewDuration
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (!widget.canAccess && !widget.previewOnly)
                AccessLockOverlay(
                  accessLevel: widget.content.accessLevel,
                  userTier: widget.userTier,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
