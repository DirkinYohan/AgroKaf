import 'package:flutter/material.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';

class PaginationDotsIndicator extends StatelessWidget {
  const PaginationDotsIndicator({
    super.key,
    required this.currentIndex,
    required this.totalCount,
    this.activeColor,
    this.inactiveColor,
    this.animationDuration,
    this.activeSize,
    this.inactiveSize,
    this.gap,
    this.activeWidth,
    this.borderRadius,
  }) : assert(currentIndex >= 0),
       assert(totalCount > 0),
       assert(currentIndex < totalCount);

  final int currentIndex;
  final int totalCount;
  final Color? activeColor;
  final Color? inactiveColor;
  final Duration? animationDuration;
  final double? activeSize;
  final double? inactiveSize;
  final double? gap;
  final double? activeWidth;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final double aSize = activeSize ?? AppSpacing.paginationDotActive;
    final double iSize = inactiveSize ?? AppSpacing.paginationDotInactive;
    final double aWidth = activeWidth ?? aSize;
    final double spacing = gap ?? AppSpacing.paginationGap;
    final Color aColor = activeColor ?? AppColors.primaryContainer;
    final Color iColor = inactiveColor ?? AppColors.outlineVariant;
    final Duration duration = animationDuration ?? AppAnimations.paginationDot;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < totalCount; i++)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeInOut,
              width: i == currentIndex ? aWidth : iSize,
              height: i == currentIndex ? aSize : iSize,
              decoration: BoxDecoration(
                color: i == currentIndex ? aColor : iColor,
                borderRadius:
                    borderRadius ??
                    BorderRadius.circular(
                      i == currentIndex ? aSize / 2 : iSize / 2,
                    ),
              ),
            ),
          ),
      ],
    );
  }
}
