import 'package:flutter/material.dart';

import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';

/// Page indicator: the active page is a wide pill, the others small dots.
class PageIndicator extends StatelessWidget {
  const PageIndicator({super.key, required this.count, required this.current})
    : assert(count > 0),
      assert(current >= 0 && current < count);

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Página ${current + 1} de $count',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < count; i++)
            AnimatedContainer(
              duration: AppDurations.medium,
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              width: i == current
                  ? AppSizes.indicatorActiveWidth
                  : AppSizes.indicatorDot,
              height: AppSizes.indicatorDot,
              decoration: BoxDecoration(
                color: i == current ? AppColors.primary : AppColors.outline,
                borderRadius: AppRadius.fullAll,
              ),
            ),
        ],
      ),
    );
  }
}
