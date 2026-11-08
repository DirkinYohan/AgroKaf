import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/features/onboarding/domain/onboarding_item.dart';
import 'package:agrokaf/features/onboarding/presentation/widgets/onboarding_illustration.dart';

/// The ONE layout shared by every onboarding page: illustration, title and
/// description, always with the same sizes, colors and spacing.
class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({super.key, required this.item});

  /// Fraction of the available height the illustration may use.
  static const double _illustrationHeightFactor = 0.55;

  final OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double illustrationSize = math.min(
          AppSizes.illustrationMax,
          math.min(
            constraints.maxWidth - AppSpacing.lg * 2,
            constraints.maxHeight * _illustrationHeightFactor,
          ),
        );
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                OnboardingIllustration(
                  imageAsset: item.imageAsset,
                  size: illustrationSize,
                  semanticLabel: item.imageSemanticLabel,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.illustrationMax + AppSpacing.lg,
                  ),
                  child: Text(
                    item.description,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
