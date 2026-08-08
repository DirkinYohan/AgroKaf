import 'package:flutter/material.dart';
import 'package:agrokaf/core/constants/app_assets.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';

class SplashLogoContainer extends StatelessWidget {
  const SplashLogoContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.shortestSide;
    final bool isTablet = screenWidth >= AppSpacing.tabletBreakpoint;

    final double logoSize =
        isTablet ? AppSpacing.logoSizeTablet : AppSpacing.logoSizeMobile;

    return Container(
      width: logoSize,
      height: logoSize,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppShadows.logoContainer,
      ),
      child: Image.asset(
        AppAssets.agrokafLogo,
        fit: BoxFit.contain,
      ),
    );
  }
}
