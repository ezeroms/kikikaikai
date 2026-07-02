import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/core/models/content_engagement.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/core/models/figure.dart';
import 'package:kikikaikai/core/providers/repository_providers.dart';

class ContentEngagementNotifier extends AsyncNotifier<ContentEngagementState> {
  @override
  Future<ContentEngagementState> build() async {
    return ref.read(contentEngagementRepositoryProvider).load();
  }

  Future<void> markViewed(String contentId) async {
    await ref.read(contentEngagementRepositoryProvider).markViewed(contentId);
    state = AsyncData(await ref.read(contentEngagementRepositoryProvider).load());
  }

  Future<void> updatePlaybackProgress({
    required String contentId,
    required int positionMs,
    int? durationMs,
    required bool completed,
  }) async {
    await ref.read(contentEngagementRepositoryProvider).updatePlaybackProgress(
          contentId: contentId,
          positionMs: positionMs,
          durationMs: durationMs,
          completed: completed,
        );
    state = AsyncData(await ref.read(contentEngagementRepositoryProvider).load());
  }
}

final contentEngagementProvider =
    AsyncNotifierProvider<ContentEngagementNotifier, ContentEngagementState>(
  ContentEngagementNotifier.new,
);

final contentsByTypeProvider =
    FutureProvider.family<List<Content>, ContentType>((ref, type) {
  return ref.read(contentRepositoryProvider).getByType(type);
});

final contentByIdProvider =
    FutureProvider.autoDispose.family<Content?, String>((ref, id) {
  return ref.read(contentRepositoryProvider).getById(id);
});

final figureByIdProvider =
    FutureProvider.autoDispose.family<Figure?, String>((ref, id) {
  return ref.read(figureRepositoryProvider).getById(id);
});

/// コンテンツ ID から紐づく Figure 一覧（五十音順）
final contentFiguresProvider =
    FutureProvider.autoDispose.family<List<Figure>, String>((ref, contentId) async {
  final content = await ref.read(contentRepositoryProvider).getById(contentId);
  if (content == null) return [];
  final figures = <Figure>[];
  for (final id in content.figureIds) {
    final figure = await ref.read(figureRepositoryProvider).getById(id);
    if (figure != null) figures.add(figure);
  }
  return sortFiguresByGojuon(figures);
});

final contentsByFigureProvider =
    FutureProvider.autoDispose.family<List<Content>, String>((ref, figureId) {
  return ref.read(contentRepositoryProvider).getByFigure(figureId);
});

final allContentsProvider = FutureProvider<List<Content>>((ref) {
  return ref.read(contentRepositoryProvider).getAll();
});
