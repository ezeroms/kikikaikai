import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/providers/providers.dart';

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

    return Column(
      children: [
        Expanded(
          child: commentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('読み込みエラー: $e')),
            data: (comments) {
              if (comments.isEmpty) {
                return Center(
                  child: Text(
                    'まだコメントはありません',
                    style: AppTypography.body(color: AppColors.muted),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              comment.authorName,
                              style: AppTypography.titleSmall(size: 13),
                            ),
                            const Spacer(),
                            Text(
                              _dateFormat.format(comment.createdAt),
                              style: AppTypography.caption(size: 11),
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
                  );
                },
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
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
    );
  }
}
