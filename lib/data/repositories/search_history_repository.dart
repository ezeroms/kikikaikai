import 'package:shared_preferences/shared_preferences.dart';

abstract class SearchHistoryRepository {
  Future<List<String>> getQueries();
  Future<void> addQuery(String query);
  Future<void> removeQuery(String query);
  Future<void> clearAll();
}

class MockSearchHistoryRepository implements SearchHistoryRepository {
  MockSearchHistoryRepository({this.maxItems = 20});

  static const _key = 'kikikaikai_search_history';
  final int maxItems;

  @override
  Future<List<String>> getQueries() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> _save(List<String> queries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, queries);
  }

  @override
  Future<void> addQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final queries = await getQueries();
    queries.remove(trimmed);
    queries.insert(0, trimmed);
    if (queries.length > maxItems) {
      queries.removeRange(maxItems, queries.length);
    }
    await _save(queries);
  }

  @override
  Future<void> removeQuery(String query) async {
    final queries = await getQueries();
    queries.remove(query);
    await _save(queries);
  }

  @override
  Future<void> clearAll() async {
    await _save([]);
  }
}
