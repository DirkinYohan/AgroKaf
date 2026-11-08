import 'package:flutter/material.dart';

import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';

/// Animated horizontal bar for a probability in [0, 1] with its percentage.
class ConfidenceBar extends StatelessWidget {
  const ConfidenceBar({
    super.key,
    required this.value,
    required this.label,
    this.color = AppColors.primary,
  });

  final double value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double clamped = value.clamp(0.0, 1.0);
    final String percent = '${(clamped * 100).toStringAsFixed(1)} %';

    return Semantics(
      label: '$label: $percent',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(label, style: textTheme.bodyMedium)),
              Text(
                percent,
                style: textTheme.titleSmall?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: AppRadius.fullAll,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: clamped),
              duration: AppDurations.slow,
              curve: Curves.easeOutCubic,
              builder: (BuildContext context, double animated, Widget? _) {
                return LinearProgressIndicator(
                  value: animated,
                  minHeight: AppSizes.confidenceBarHeight,
                  color: color,
                  backgroundColor: AppColors.surfaceVariant,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
