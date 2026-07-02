import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/shared/widgets/content_card.dart';
import 'package:kikikaikai/shared/widgets/mini_player_bar.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';
  bool _wasRouteCurrent = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _autoFocusIfHistoryEmpty() async {
    if (_query.isNotEmpty) return;

    final cached = ref.read(searchHistoryProvider).valueOrNull;
    final history =
        cached ?? await ref.read(searchHistoryProvider.future) ?? [];
    if (!mounted || history.isNotEmpty) return;

    _focusNode.requestFocus();
  }

  void _onRouteBecameCurrent() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoFocusIfHistoryEmpty();
    });
  }

  Future<void> _performSearch(String raw) async {
    final query = raw.trim();
    setState(() {
      _query = query;
      _controller.text = query;
    });
    if (query.isEmpty) return;
    await ref.read(searchHistoryProvider.notifier).addQuery(query);
    _focusNode.unfocus();
  }

  List<Content> _filterContents(List<Content> contents, String query) {
    final q = query.toLowerCase();
    return contents.where((c) {
      return c.title.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q) ||
          c.type.label.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final contentsAsync = ref.watch(allContentsProvider);
    final historyAsync = ref.watch(searchHistoryProvider);
    final isRouteCurrent = ModalRoute.of(context)?.isCurrent ?? true;

    if (isRouteCurrent && !_wasRouteCurrent) {
      _onRouteBecameCurrent();
    }
    _wasRouteCurrent = isRouteCurrent;

    return Scaffold(
      appBar: AppBar(title: const Text('検索')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              cursorColor: AppColors.onBase,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'タイトル・説明で検索',
                prefixIcon: const Icon(LucideIcons.search),
                prefixIconColor: WidgetStateColor.resolveWith((states) {
                  if (states.contains(WidgetState.focused)) {
                    return AppColors.onBase;
                  }
                  return AppColors.muted;
                }),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppColors.onBase,
                    width: 1.5,
                  ),
                ),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                          _autoFocusIfHistoryEmpty();
                        },
                        icon: const Icon(LucideIcons.x),
                      )
                    : null,
              ),
              onChanged: (value) {
                if (value.trim().isEmpty) {
                  setState(() => _query = '');
                }
              },
              onSubmitted: _performSearch,
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? _SearchHistoryPanel(
                    historyAsync: historyAsync,
                    onSelect: _performSearch,
                    onRemove: (query) {
                      ref
                          .read(searchHistoryProvider.notifier)
                          .removeQuery(query);
                    },
                    onClearAll: () async {
                      await ref
                          .read(searchHistoryProvider.notifier)
                          .clearAll();
                      if (mounted) await _autoFocusIfHistoryEmpty();
                    },
                  )
                : contentsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('読み込みエラー: $e')),
                    data: (contents) {
                      final filtered = _filterContents(contents, _query);

                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(
                            '「$_query」に一致するコンテンツがありません',
                            style: AppTypography.body(color: AppColors.muted),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          16 + miniPlayerScrollPadding(context),
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 24),
                        itemBuilder: (context, index) {
                          return ContentCard(content: filtered[index]);
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

class _SearchHistoryPanel extends StatelessWidget {
  const _SearchHistoryPanel({
    required this.historyAsync,
    required this.onSelect,
    required this.onRemove,
    required this.onClearAll,
  });

  final AsyncValue<List<String>> historyAsync;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onRemove;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('読み込みエラー: $e')),
      data: (history) {
        if (history.isEmpty) {
          return const SizedBox.shrink();
        }

        return ListView(
          padding: EdgeInsets.fromLTRB(
            8,
            0,
            8,
            16 + miniPlayerScrollPadding(context),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                children: [
                  Text(
                    '検索履歴',
                    style: AppTypography.label(
                      size: 13,
                      color: AppColors.muted,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onClearAll,
                    child: Text(
                      'すべて削除',
                      style: AppTypography.label(size: 12),
                    ),
                  ),
                ],
              ),
            ),
            ...history.map(
              (query) => ListTile(
                leading: const Icon(
                  LucideIcons.history,
                  color: AppColors.muted,
                  size: 20,
                ),
                title: Text(
                  query,
                  style: AppTypography.body(size: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(
                    LucideIcons.x,
                    size: 18,
                    color: AppColors.muted,
                  ),
                  onPressed: () => onRemove(query),
                  tooltip: '削除',
                ),
                onTap: () => onSelect(query),
              ),
            ),
          ],
        );
      },
    );
  }
}
