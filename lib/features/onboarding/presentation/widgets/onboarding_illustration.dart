import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';

/// Square, rounded illustration card with a subtle floating motion.
///
/// The images already contain their own artwork (phone mockups, icons), so
/// nothing is painted on top of them. The motion is disabled when the user
/// asks the OS to reduce animations.
class OnboardingIllustration extends StatefulWidget {
  const OnboardingIllustration({
    super.key,
    required this.imageAsset,
    required this.size,
    required this.semanticLabel,
  });

  final String imageAsset;
  final double size;
  final String semanticLabel;

  @override
  State<OnboardingIllustration> createState() => _OnboardingIllustrationState();
}

class _OnboardingIllustrationState extends State<OnboardingIllustration>
    with SingleTickerProviderStateMixin {
  static const double _floatOffset = 6;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.float,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    final Widget card = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: AppColors.illustrationBackground,
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        widget.imageAsset,
        fit: BoxFit.cover,
        semanticLabel: widget.semanticLabel,
        cacheWidth: (widget.size * MediaQuery.devicePixelRatioOf(context))
            .round(),
      ),
    );

    if (reduceMotion) return card;
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double dy =
            math.sin(_controller.value * 2 * math.pi) * _floatOffset;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: card,
    );
  }
}
