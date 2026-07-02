import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/user_tier.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/features/content/widgets/audio_detail_comments_tab.dart';
import 'package:kikikaikai/features/content/widgets/audio_detail_player_header.dart';
import 'package:kikikaikai/features/content/widgets/audio_detail_transcript_tab.dart';
import 'package:kikikaikai/features/content/widgets/content_detail_main_tab.dart';
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

  bool get _hasTranscriptTab => widget.content.type.hasTranscriptTab;

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showAudioPlayer = widget.content.type.isAudioPlayback &&
        widget.content.mediaUrl != null &&
        (widget.canAccess || widget.previewOnly);

    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        title: Text(widget.content.type.label),
        backgroundColor: AppColors.base,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorColor: AppColors.onBase,
                labelColor: AppColors.onBase,
                unselectedLabelColor: AppColors.muted,
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                tabs: [
                  const Tab(text: '本編'),
                  if (_hasTranscriptTab) const Tab(text: '書き起こし'),
                  const Tab(text: 'コメント'),
                ],
              ),
              if (showAudioPlayer)
                AudioDetailPlayerHeader(
                  key: ValueKey(widget.content.id),
                  content: widget.content,
                  previewLimit:
                      widget.previewOnly ? const Duration(seconds: 30) : null,
                ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ContentDetailMainTab(
                      content: widget.content,
                      canAccess: widget.canAccess,
                      previewOnly: widget.previewOnly,
                    ),
                    if (_hasTranscriptTab)
                      AudioDetailTranscriptTab(content: widget.content),
                    AudioDetailCommentsTab(contentId: widget.content.id),
                  ],
                ),
              ),
            ],
          ),
          if (!widget.canAccess && !widget.previewOnly)
            AccessLockOverlay(
              accessLevel: widget.content.accessLevel,
              userTier: widget.userTier,
            ),
        ],
      ),
    );
  }
}
