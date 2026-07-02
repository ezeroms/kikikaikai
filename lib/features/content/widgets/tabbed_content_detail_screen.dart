import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
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
  VoidCallback? _onPlaybackSessionChanged;
  bool _visibilityUpdateScheduled = false;

  bool get _hasTranscriptTab => widget.content.type.hasTranscriptTab;

  bool get _showAudioPlayer =>
      widget.content.type.isAudioPlayback &&
      widget.content.mediaUrl != null &&
      (widget.canAccess || widget.previewOnly);

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

    nestedScroll.outerController.removeListener(_updateMiniPlayerVisibility);
    nestedScroll.outerController.addListener(_updateMiniPlayerVisibility);
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
    nestedScroll?.outerController.removeListener(_updateMiniPlayerVisibility);
    final handler = MediaPlayback.handler;
    if (handler != null && _onPlaybackSessionChanged != null) {
      handler.sessionActiveNotifier.removeListener(_onPlaybackSessionChanged!);
      handler.currentContentNotifier.removeListener(_onPlaybackSessionChanged!);
    }
    _tabController.dispose();
    super.dispose();
  }

  bool _isPlayerHeaderFullyHidden() {
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

    final headerContext = _playerHeaderKey.currentContext;
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
    if (!_showAudioPlayer) {
      PlaybackDebugLog.log(
        'DetailMiniPlayer',
        'hide content=${widget.content.id} reason=no-audio-player',
      );
      _writeDetailMiniPlayerVisible(false);
      return;
    }

    final nestedScroll = _nestedScrollKey.currentState;
    final outer = nestedScroll?.outerController;
    final hasOuter = outer?.hasClients ?? false;
    final pixels = hasOuter ? outer!.position.pixels : null;
    final maxExtent = hasOuter ? outer!.position.maxScrollExtent : null;
    final headerHidden = _isPlayerHeaderFullyHidden();
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
        const Tab(text: '本編'),
        if (_hasTranscriptTab) const Tab(text: '書き起こし'),
        const Tab(text: 'コメント'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final showAudioPlayer = _showAudioPlayer;
    final tabBar = _buildTabBar();
    final isKikikaikai = widget.content.type == ContentType.kikikaikai;
    final tabBarHeight = tabBar.preferredSize.height;

    return Stack(
      children: [
        if (isKikikaikai)
          const Positioned.fill(
            child: IgnorePointer(
              child: KikikaikaiDetailBackground(),
            ),
          ),
        Scaffold(
          backgroundColor:
              isKikikaikai ? Colors.transparent : AppColors.base,
          appBar: AppBar(
            title: isKikikaikai
                ? const SizedBox.shrink()
                : Text(widget.content.type.label),
            backgroundColor:
                isKikikaikai ? Colors.transparent : AppColors.base,
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
                  color: widget.isDownloaded
                      ? AppColors.primary
                      : AppColors.secondary,
                ),
                tooltip: widget.isDownloaded ? 'ダウンロード済み' : 'ダウンロード',
              ),
            ],
          ),
          body: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  _updateMiniPlayerVisibility();
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
                        SliverOverlapAbsorber(
                          handle:
                              NestedScrollView.sliverOverlapAbsorberHandleFor(
                            context,
                          ),
                          sliver: SliverPersistentHeader(
                            pinned: true,
                            delegate: ContentDetailTabBarSliver(
                              tabBar: tabBar,
                              backgroundColor: isKikikaikai
                                  ? Colors.transparent
                                  : AppColors.base,
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
                                  contentId: widget.content.id,
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
