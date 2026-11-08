import 'package:flutter/material.dart';

import 'package:agrokaf/core/constants/app_assets.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';

/// The AgroKaf logo (leaf + wordmark) at a given height.
///
/// The logo artwork has a white background, so on the warm app background it
/// is shown inside a white rounded card ([framed]) to look intentional.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, required this.height, this.framed = false});

  static const String heroTag = 'agrokaf-logo';
  static const String _semanticLabel = 'Logo de AgroKaf';

  final double height;
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final Widget image = Image.asset(
      AppAssets.logo,
      height: framed ? height - AppSpacing.xs * 2 : height,
      fit: BoxFit.contain,
      semanticLabel: _semanticLabel,
    );
    return Hero(
      tag: heroTag,
      child: framed
          ? Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.mdAll,
                border: Border.all(color: AppColors.surfaceVariant),
              ),
              child: image,
            )
          : image,
    );
  }
}
