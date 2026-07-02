import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/models/access_level.dart';
import 'package:kikikaikai/core/models/user_tier.dart';

class AccessLockOverlay extends StatelessWidget {
  const AccessLockOverlay({
    super.key,
    required this.accessLevel,
    required this.userTier,
  });

  final AccessLevel accessLevel;
  final UserTier userTier;

  bool get _isLocked => !userTier.canAccess(accessLevel);

  @override
  Widget build(BuildContext context) {
    if (!_isLocked) return const SizedBox.shrink();

    final needsSignup = userTier == UserTier.guest;
    final message = needsSignup
        ? '品品団地アカウントが必要です'
        : '団地住民限定コンテンツです';
    final buttonLabel = needsSignup ? '入居登録する' : '団地住民になる';
    final route = needsSignup ? '/signup' : '/upgrade';

    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, color: AppColors.secondary, size: 48),
              const SizedBox(height: 16),
              Text(
                accessLevel.label,
                style: AppTypography.overline(),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: AppTypography.title(size: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.push(route),
                child: Text(buttonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
