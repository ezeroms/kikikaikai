import 'dart:convert';

import 'package:kikikaikai/core/models/content_engagement.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ContentEngagementRepository {
  Future<ContentEngagementState> load();
  Future<void> markViewed(String contentId);
  Future<void> updatePlaybackProgress({
    required String contentId,
    required int positionMs,
    int? durationMs,
    required bool completed,
  });
}

class MockContentEngagementRepository implements ContentEngagementRepository {
  static const _viewedKey = 'kikikaikai_viewed_content_ids';
  static const _playbackKey = 'kikikaikai_playback_progress';

  @override
  Future<ContentEngagementState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final viewed = (prefs.getStringList(_viewedKey) ?? []).toSet();
    final playbackRaw = prefs.getString(_playbackKey);
    final playback = <String, ContentPlaybackProgress>{};

    if (playbackRaw != null && playbackRaw.isNotEmpty) {
      final decoded = jsonDecode(playbackRaw) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        playback[entry.key] = ContentPlaybackProgress.fromJson(
          Map<String, dynamic>.from(entry.value as Map),
        );
      }
    }

    return ContentEngagementState(viewedIds: viewed, playback: playback);
  }

  @override
  Future<void> markViewed(String contentId) async {
    final prefs = await SharedPreferences.getInstance();
    final viewed = prefs.getStringList(_viewedKey) ?? [];
    if (viewed.contains(contentId)) return;
    viewed.add(contentId);
    await prefs.setStringList(_viewedKey, viewed);
  }

  @override
  Future<void> updatePlaybackProgress({
    required String contentId,
    required int positionMs,
    int? durationMs,
    required bool completed,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final state = await load();
    final current = state.playback[contentId];
    final resolvedDuration = durationMs ?? current?.durationMs;
    final resolvedCompleted = completed ||
        current?.completed == true ||
        _isCompleted(positionMs, resolvedDuration);

    final next = ContentPlaybackProgress(
      positionMs: positionMs,
      durationMs: resolvedDuration,
      completed: resolvedCompleted,
    );

    if (current != null &&
        current.positionMs == next.positionMs &&
        current.durationMs == next.durationMs &&
        current.completed == next.completed) {
      return;
    }

    final playback = Map<String, ContentPlaybackProgress>.from(state.playback)
      ..[contentId] = next;

    final encoded = {
      for (final entry in playback.entries) entry.key: entry.value.toJson(),
    };
    await prefs.setString(_playbackKey, jsonEncode(encoded));
  }

  bool _isCompleted(int positionMs, int? durationMs) {
    if (durationMs == null || durationMs <= 0) return false;
    return positionMs >= (durationMs * 0.95).round();
  }
}
