import 'package:kikikaikai/core/models/access_level.dart';

enum UserTier {
  guest,
  member,
  resident;

  String get label => switch (this) {
        UserTier.guest => '見学者',
        UserTier.member => '品品団地アカウント',
        UserTier.resident => '団地住民',
      };

  bool canAccess(AccessLevel level) => switch (level) {
        AccessLevel.public => true,
        AccessLevel.member => this != UserTier.guest,
        AccessLevel.resident => this == UserTier.resident,
      };
}
