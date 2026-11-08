import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';

/// Three dots that pulse in sequence (brand loading indicator).
class AnimatedLoadingDots extends StatefulWidget {
  const AnimatedLoadingDots({super.key, this.color = AppColors.primary});

  final Color color;

  @override
  State<AnimatedLoadingDots> createState() => _AnimatedLoadingDotsState();
}

class _AnimatedLoadingDotsState extends State<AnimatedLoadingDots>
    with SingleTickerProviderStateMixin {
  static const int _dotCount = 3;
  static const double _phaseShift = 0.2;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.loadingDots,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (int i = 0; i < _dotCount; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: Transform.scale(
                    scale: _scaleFor(i),
                    child: Container(
                      width: AppSizes.loadingDot,
                      height: AppSizes.loadingDot,
                      decoration: BoxDecoration(
                        color: widget.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Smooth 0.4 -> 1.0 pulse, shifted per dot.
  double _scaleFor(int index) {
    final double t = (_controller.value - index * _phaseShift) % 1.0;
    final double wave = math.sin(t * math.pi).clamp(0.0, 1.0);
    return 0.4 + 0.6 * wave;
  }
}
