import 'package:kikikaikai/core/models/app_user.dart';
import 'package:kikikaikai/core/models/user_tier.dart';

abstract final class DummyAccounts {
  static const demoEmail = 'ezeroms@gmail.com';
  static const demoPassword = 'chooning';

  static const demoUser = AppUser(
    id: 'user_ezeroms',
    email: demoEmail,
    displayName: 'ezeroms',
    tier: UserTier.resident,
    avatarAsset: 'assets/avatar/ezeroms.png',
  );
}
