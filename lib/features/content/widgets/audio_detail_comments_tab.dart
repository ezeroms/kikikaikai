import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/format/format_content_date.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/features/content/widgets/content_detail_nested_tab_scroll.dart';
import 'package:kikikaikai/shared/widgets/comment_author_avatar.dart';
import 'package:kikikaikai/shared/widgets/glass_card.dart';
import 'package:kikikaikai/shared/widgets/mini_player_bar.dart';
import 'package:kikikaikai/shared/widgets/timestamp_link_text.dart';

class AudioDetailCommentsTab extends ConsumerStatefulWidget {
  const AudioDetailCommentsTab({
    super.key,
    required this.content,
    this.previewLimit,
  });

  final Content content;
  final Duration? previewLimit;

  @override
  ConsumerState<AudioDetailCommentsTab> createState() =>
      _AudioDetailCommentsTabState();
}

class _AudioDetailCommentsTabState extends ConsumerState<AudioDetailCommentsTab> {
  final _controller = TextEditingController();

  static const _sendDisabledOpacity = 0.35;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onCommentTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onCommentTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onCommentTextChanged() {
    setState(() {});
  }

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  void _unfocusCommentInput() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _submit() async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    await ref
        .read(contentCommentsProvider(widget.content.id).notifier)
        .addComment(text);
    _controller.clear();
    if (!mounted) return;
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(contentCommentsProvider(widget.content.id));
    final detailMiniPlayerPad = ref.watch(detailMiniPlayerVisibleProvider)
        ? MiniPlayerBar.height
        : 0.0;

    return Padding(
      padding: EdgeInsets.only(bottom: detailMiniPlayerPad),
      child: Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _unfocusCommentInput,
            behavior: HitTestBehavior.translucent,
            child: commentsAsync.when(
            loading: () => Builder(
              builder: (context) => buildContentDetailNestedScrollSlivers(
                context,
                slivers: const [
                  SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            ),
            error: (e, _) => Builder(
              builder: (context) => buildContentDetailNestedScrollSlivers(
                context,
                slivers: [
                  SliverFillRemaining(
                    child: Center(child: Text('読み込みエラー: $e')),
                  ),
                ],
              ),
            ),
            data: (comments) {
              if (comments.isEmpty) {
                return Builder(
                  builder: (context) => buildContentDetailNestedScrollSlivers(
                    context,
                    slivers: [
                      SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'まだコメントはありません',
                            style: AppTypography.body(color: AppColors.muted),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Builder(
                builder: (context) => buildContentDetailNestedScrollSlivers(
                  context,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        kContentDetailTabContentTopSpacing,
                        20,
                        16,
                      ),
                      sliver: SliverList.separated(
                        itemCount: comments.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return GlassCard(
                            padding: GlassCard.kCommentPadding,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommentAuthorAvatar(
                                  avatarAsset: comment.authorAvatarAsset,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            comment.authorName,
                                            style: AppTypography.titleSmall(
                                              size: 13,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            formatContentDate(
                                              comment.createdAt,
                                            ),
                                            style: AppTypography.caption(
                                              size: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      TimestampLinkText(
                                        text: comment.body,
                                        style: AppTypography.body(size: 14),
                                        content: widget.content
                                            .type
                                            .supportsMediaTimestampLinks
                                            ? widget.content
                                            : null,
                                        previewLimit: widget.previewLimit,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'コメントを入力',
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(
                          color: AppColors.onBase,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _canSubmit ? _submit : null,
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.onBase,
                    disabledForegroundColor: AppColors.onBase.withValues(
                      alpha: _sendDisabledOpacity,
                    ),
                  ),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }
}
