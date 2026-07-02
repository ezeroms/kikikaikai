import 'dart:convert';

import 'package:kikikaikai/core/models/content_comment.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ContentCommentsRepository {
  Future<List<ContentComment>> load(String contentId);
  Future<void> add(String contentId, String body);
}

class MockContentCommentsRepository implements ContentCommentsRepository {
  static const _storageKey = 'kikikaikai_content_comments';

  @override
  Future<List<ContentComment>> load(String contentId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final items = decoded[contentId];
    if (items is! List) return [];

    return items
        .map(
          (item) => ContentComment.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> add(String contentId, String body) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    final decoded = raw == null || raw.isEmpty
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(jsonDecode(raw) as Map);

    final current = (decoded[contentId] as List?)?.toList() ?? <dynamic>[];
    final next = ContentComment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      body: trimmed,
      createdAt: DateTime.now(),
    );
    current.insert(0, next.toJson());
    decoded[contentId] = current;
    await prefs.setString(_storageKey, jsonEncode(decoded));
  }
}
