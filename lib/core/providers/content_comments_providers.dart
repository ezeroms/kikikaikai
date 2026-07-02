import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/core/models/content_comment.dart';
import 'package:kikikaikai/core/providers/repository_providers.dart';

class ContentCommentsNotifier
    extends FamilyAsyncNotifier<List<ContentComment>, String> {
  @override
  Future<List<ContentComment>> build(String contentId) async {
    return ref.read(contentCommentsRepositoryProvider).load(contentId);
  }

  Future<void> addComment(String body) async {
    final contentId = arg;
    await ref.read(contentCommentsRepositoryProvider).add(contentId, body);
    state = AsyncData(await ref.read(contentCommentsRepositoryProvider).load(contentId));
  }
}

final contentCommentsProvider = AsyncNotifierProvider.family<
    ContentCommentsNotifier, List<ContentComment>, String>(
  ContentCommentsNotifier.new,
);
