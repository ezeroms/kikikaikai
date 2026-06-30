import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/models/access_level.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/shared/widgets/paper_tape_heading.dart';
import 'package:kikikaikai/shared/widgets/mini_player_bar.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentsAsync = ref.watch(allContentsProvider);
    final userTier = ref.watch(userTierProvider);
    final dateFormat = DateFormat('yyyy.MM.dd');

    return Scaffold(
      appBar: AppBar(title: const Text('検索')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'タイトル・説明で検索',
                prefixIcon: const Icon(LucideIcons.search),
              ),
              onChanged: (value) => setState(() => _query = value.trim()),
            ),
          ),
          Expanded(
            child: contentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('読み込みエラー: $e')),
              data: (contents) {
                final filtered = _query.isEmpty
                    ? contents
                    : contents.where((c) {
                        final q = _query.toLowerCase();
                        return c.title.toLowerCase().contains(q) ||
                            c.description.toLowerCase().contains(q) ||
                            c.type.label.contains(_query);
                      }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _query.isEmpty
                          ? 'キーワードを入力してください'
                          : '「$_query」に一致するコンテンツがありません',
                      style: AppTypography.body(color: AppColors.shuttleGray),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    16 + miniPlayerScrollPadding(context),
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final content = filtered[index];
                    final locked = !userTier.canAccess(content.accessLevel);
                    return InkWell(
                      onTap: () => context.push('/content/${content.id}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PaperTapeHeading(
                            title: content.title,
                            date: dateFormat.format(content.publishedAt),
                            isOdd: index.isOdd,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 8),
                            child: Row(
                              children: [
                                Text(
                                  content.type.label,
                                  style: AppTypography.label(
                                    size: 11,
                                    color: AppColors.mangoTango,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    content.description,
                                    style: AppTypography.body(
                                      size: 13,
                                      color: AppColors.shuttleGray,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (locked)
                                  const Icon(
                                    Icons.lock_outline,
                                    size: 16,
                                    color: AppColors.mangoTango,
                                  ),
                                if (content.accessLevel != AccessLevel.public)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.riverRoad,
                                      ),
                                    ),
                                    child: Text(
                                      content.accessLevel.label,
                                      style: AppTypography.label(size: 10),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
