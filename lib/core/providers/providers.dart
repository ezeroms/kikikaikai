import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/core/models/app_user.dart';
import 'package:kikikaikai/core/models/author.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/core/models/user_tier.dart';
import 'package:kikikaikai/data/repositories/auth_repository.dart';
import 'package:kikikaikai/data/repositories/content_repository.dart';
import 'package:kikikaikai/data/repositories/mock_auth_repository.dart';
import 'package:kikikaikai/data/repositories/mock_content_repository.dart';
import 'package:kikikaikai/data/repositories/saved_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => MockAuthRepository(),
);

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => MockContentRepository(),
);

final authorRepositoryProvider = Provider<AuthorRepository>(
  (ref) => MockAuthorRepository(),
);

final savedRepositoryProvider = Provider<SavedRepository>(
  (ref) => MockSavedRepository(),
);

class SavedNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    return ref.read(savedRepositoryProvider).getSavedIds();
  }

  Future<void> toggle(String contentId) async {
    await ref.read(savedRepositoryProvider).toggle(contentId);
    state = AsyncData(await ref.read(savedRepositoryProvider).getSavedIds());
  }

  Future<void> refresh() async {
    state = AsyncData(await ref.read(savedRepositoryProvider).getSavedIds());
  }
}

final savedIdsProvider = AsyncNotifierProvider<SavedNotifier, List<String>>(
  SavedNotifier.new,
);

final isSavedProvider = FutureProvider.family<bool, String>((ref, id) async {
  ref.watch(savedIdsProvider);
  return ref.read(savedRepositoryProvider).isSaved(id);
});

final savedContentsProvider = FutureProvider<List<Content>>((ref) async {
  final ids = ref.watch(savedIdsProvider).valueOrNull ?? [];
  if (ids.isEmpty) return [];
  final all = await ref.read(contentRepositoryProvider).getAll();
  final idSet = ids.toSet();
  return all.where((c) => idSet.contains(c.id)).toList();
});

class AuthNotifier extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    return ref.read(authRepositoryProvider).getCurrentUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(
            email: email,
            password: password,
          ),
    );
  }

  Future<void> signup(
    String email,
    String password,
    String displayName,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signup(
            email: email,
            password: password,
            displayName: displayName,
          ),
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }

  Future<void> upgradeToResident() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).upgradeToResident(),
    );
  }

  Future<void> enterAsGuest() async {
    await ref.read(authRepositoryProvider).enterAsGuest();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AppUser?>(
  AuthNotifier.new,
);

final userTierProvider = Provider<UserTier>((ref) {
  final user = ref.watch(authProvider).valueOrNull;
  return user?.tier ?? UserTier.guest;
});

final contentsByTypeProvider =
    FutureProvider.family<List<Content>, ContentType>((ref, type) {
  return ref.read(contentRepositoryProvider).getByType(type);
});

final contentByIdProvider =
    FutureProvider.family<Content?, String>((ref, id) {
  return ref.read(contentRepositoryProvider).getById(id);
});

final authorByIdProvider =
    FutureProvider.family<Author?, String>((ref, id) {
  return ref.read(authorRepositoryProvider).getById(id);
});

final allContentsProvider = FutureProvider<List<Content>>((ref) {
  return ref.read(contentRepositoryProvider).getAll();
});
