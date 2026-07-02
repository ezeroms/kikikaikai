import 'package:kikikaikai/core/models/user_tier.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.tier,
    this.avatarAsset,
  });

  final String id;
  final String email;
  final String displayName;
  final UserTier tier;
  final String? avatarAsset;

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    UserTier? tier,
    String? avatarAsset,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      tier: tier ?? this.tier,
      avatarAsset: avatarAsset ?? this.avatarAsset,
    );
  }
}
