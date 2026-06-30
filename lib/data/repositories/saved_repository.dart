import 'package:shared_preferences/shared_preferences.dart';

abstract class SavedRepository {
  Future<List<String>> getSavedIds();
  Future<bool> isSaved(String contentId);
  Future<void> toggle(String contentId);
}

class MockSavedRepository implements SavedRepository {
  static const _key = 'kikikaikai_saved_ids';

  @override
  Future<List<String>> getSavedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  @override
  Future<bool> isSaved(String contentId) async {
    final ids = await getSavedIds();
    return ids.contains(contentId);
  }

  @override
  Future<void> toggle(String contentId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await getSavedIds();
    if (ids.contains(contentId)) {
      ids.remove(contentId);
    } else {
      ids.add(contentId);
    }
    await prefs.setStringList(_key, ids);
  }
}
