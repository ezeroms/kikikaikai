import 'dart:convert';

import 'package:kikikaikai/core/models/app_user.dart';
import 'package:kikikaikai/core/models/user_tier.dart';
import 'package:kikikaikai/data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthRepository implements AuthRepository {
  static const _userKey = 'kikikaikai_user';

  @override
  Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return AppUser(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      tier: UserTier.values.byName(map['tier'] as String),
    );
  }

  Future<void> _saveUser(AppUser? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_userKey);
      return;
    }
    await prefs.setString(
      _userKey,
      jsonEncode({
        'id': user.id,
        'email': user.email,
        'displayName': user.displayName,
        'tier': user.tier.name,
      }),
    );
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final user = AppUser(
      id: 'user_${email.hashCode}',
      email: email,
      displayName: email.split('@').first,
      tier: UserTier.member,
    );
    await _saveUser(user);
    return user;
  }

  @override
  Future<AppUser> signup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final user = AppUser(
      id: 'user_${email.hashCode}',
      email: email,
      displayName: displayName,
      tier: UserTier.member,
    );
    await _saveUser(user);
    return user;
  }

  @override
  Future<void> logout() => _saveUser(null);

  @override
  Future<AppUser> upgradeToResident() async {
    final current = await getCurrentUser();
    if (current == null) {
      throw StateError('ログインが必要です');
    }
    final upgraded = current.copyWith(tier: UserTier.resident);
    await _saveUser(upgraded);
    return upgraded;
  }

  @override
  Future<void> enterAsGuest() async {
    await _saveUser(null);
  }
}
