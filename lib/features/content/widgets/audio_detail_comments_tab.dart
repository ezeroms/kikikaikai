import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/features/content/widgets/content_detail_nested_tab_scroll.dart';
import 'package:kikikaikai/shared/widgets/comment_author_avatar.dart';
import 'package:kikikaikai/shared/widgets/mini_player_bar.dart';

class AudioDetailCommentsTab extends ConsumerStatefulWidget {
  const AudioDetailCommentsTab({super.key, required this.contentId});

  final String contentId;

  @override
  ConsumerState<AudioDetailCommentsTab> createState() =>
      _AudioDetailCommentsTabState();
}

class _AudioDetailCommentsTabState extends ConsumerState<AudioDetailCommentsTab> {
  final _controller = TextEditingController();
  final _dateFormat = DateFormat('yyyy.MM.dd HH:mm');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    await ref
        .read(contentCommentsProvider(widget.contentId).notifier)
        .addComment(text);
    _controller.clear();
    if (!mounted) return;
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(contentCommentsProvider(widget.contentId));
    final currentUser = ref.watch(authProvider).valueOrNull;
    final detailMiniPlayerPad = ref.watch(detailMiniPlayerVisibleProvider)
        ? MiniPlayerBar.height
        : 0.0;

    return Padding(
      padding: EdgeInsets.only(bottom: detailMiniPlayerPad),
      child: Column(
      children: [
        Expanded(
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
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
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
                                            _dateFormat.format(
                                              comment.createdAt,
                                            ),
                                            style: AppTypography.caption(
                                              size: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        comment.body,
                                        style: AppTypography.body(size: 14),
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
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CommentAuthorAvatar(
                  avatarAsset: currentUser?.avatarAsset,
                  radius: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: 'コメントを入力',
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _submit,
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
