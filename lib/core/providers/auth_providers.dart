import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/core/models/app_user.dart';
import 'package:kikikaikai/core/models/user_tier.dart';
import 'package:kikikaikai/core/providers/repository_providers.dart';

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
