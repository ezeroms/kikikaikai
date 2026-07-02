import 'package:shared_preferences/shared_preferences.dart';

abstract class DownloadsRepository {
  Future<List<String>> getDownloadIds();
  Future<bool> isDownloaded(String contentId);
  Future<void> toggleDownload(String contentId);
}

class MockDownloadsRepository implements DownloadsRepository {
  // 旧キー名を維持し、既存ユーザーのデータを引き継ぐ
  static const _storageKey = 'kikikaikai_saved_ids';

  @override
  Future<List<String>> getDownloadIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_storageKey) ?? [];
  }

  @override
  Future<bool> isDownloaded(String contentId) async {
    final ids = await getDownloadIds();
    return ids.contains(contentId);
  }

  @override
  Future<void> toggleDownload(String contentId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await getDownloadIds();
    if (ids.contains(contentId)) {
      ids.remove(contentId);
    } else {
      ids.add(contentId);
    }
    await prefs.setStringList(_storageKey, ids);
  }
}
