import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/providers/repository_providers.dart';

class DownloadsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    return ref.read(downloadsRepositoryProvider).getDownloadIds();
  }

  Future<void> toggleDownload(String contentId) async {
    await ref.read(downloadsRepositoryProvider).toggleDownload(contentId);
    state = AsyncData(
      await ref.read(downloadsRepositoryProvider).getDownloadIds(),
    );
  }

  Future<void> refresh() async {
    state = AsyncData(
      await ref.read(downloadsRepositoryProvider).getDownloadIds(),
    );
  }
}

final downloadIdsProvider =
    AsyncNotifierProvider<DownloadsNotifier, List<String>>(
  DownloadsNotifier.new,
);

final isDownloadedProvider = FutureProvider.family<bool, String>((ref, id) async {
  ref.watch(downloadIdsProvider);
  return ref.read(downloadsRepositoryProvider).isDownloaded(id);
});

final downloadedContentsProvider = FutureProvider<List<Content>>((ref) async {
  final ids = ref.watch(downloadIdsProvider).valueOrNull ?? [];
  if (ids.isEmpty) return [];
  final all = await ref.read(contentRepositoryProvider).getAll();
  final idSet = ids.toSet();
  return all.where((c) => idSet.contains(c.id)).toList();
});
