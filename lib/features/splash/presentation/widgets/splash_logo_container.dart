import 'package:flutter/material.dart';

import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/widgets/app_logo.dart';

/// White rounded card holding the logo (splash centerpiece).
class SplashLogoContainer extends StatelessWidget {
  const SplashLogoContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: AppShadows.elevated,
      ),
      child: const AppLogo(height: AppSizes.logoSplash),
    );
  }
}
