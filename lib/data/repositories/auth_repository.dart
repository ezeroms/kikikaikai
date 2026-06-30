import 'package:kikikaikai/core/models/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> getCurrentUser();
  Future<AppUser> login({required String email, required String password});
  Future<AppUser> signup({
    required String email,
    required String password,
    required String displayName,
  });
  Future<void> logout();
  Future<AppUser> upgradeToResident();
  Future<void> enterAsGuest();
}
