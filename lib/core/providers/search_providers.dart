import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/core/providers/repository_providers.dart';

class SearchHistoryNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    return ref.read(searchHistoryRepositoryProvider).getQueries();
  }

  Future<void> addQuery(String query) async {
    await ref.read(searchHistoryRepositoryProvider).addQuery(query);
    state = AsyncData(await ref.read(searchHistoryRepositoryProvider).getQueries());
  }

  Future<void> removeQuery(String query) async {
    await ref.read(searchHistoryRepositoryProvider).removeQuery(query);
    state = AsyncData(await ref.read(searchHistoryRepositoryProvider).getQueries());
  }

  Future<void> clearAll() async {
    await ref.read(searchHistoryRepositoryProvider).clearAll();
    state = const AsyncData([]);
  }
}

final searchHistoryProvider =
    AsyncNotifierProvider<SearchHistoryNotifier, List<String>>(
  SearchHistoryNotifier.new,
);
