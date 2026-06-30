import 'package:kikikaikai/core/models/user_tier.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.tier,
  });

  final String id;
  final String email;
  final String displayName;
  final UserTier tier;

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    UserTier? tier,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      tier: tier ?? this.tier,
    );
  }
}
