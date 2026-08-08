import 'dart:math';
import 'package:flutter/material.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';

class OnboardingIllustrationCard extends StatefulWidget {
  const OnboardingIllustrationCard({
    super.key,
    required this.imageAsset,
    this.maxSize,
    this.radius,
    this.animationDuration = AppAnimations.float,
    this.floatOffset = 10.0,
    this.backgroundColor,
    this.padding,
    this.border,
    this.imageBoxFit = BoxFit.cover,
    this.imageWidthFactor,
    this.imageHeightFactor,
    this.enableGradientOverlay = true,
    this.overlayWidget,
    this.aspectRatio = 1.0,
    this.boxShadows,
    this.backgroundGradient,
  });

  final String imageAsset;
  final double? maxSize;
  final BorderRadiusGeometry? radius;
  final Duration animationDuration;
  final double floatOffset;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final BoxBorder? border;
  final BoxFit imageBoxFit;
  final double? imageWidthFactor;
  final double? imageHeightFactor;
  final bool enableGradientOverlay;
  final Widget? overlayWidget;
  final double aspectRatio;
  final List<BoxShadow>? boxShadows;
  final Gradient? backgroundGradient;

  @override
  State<OnboardingIllustrationCard> createState() =>
      _OnboardingIllustrationCardState();
}

class _OnboardingIllustrationCardState extends State<OnboardingIllustrationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.maxSize ?? AppSpacing.illustrationMaxSize;
    final BorderRadiusGeometry borderRadius =
        widget.radius ?? BorderRadius.circular(AppSpacing.radius2xl);
    final List<BoxShadow> effectiveShadows =
        widget.boxShadows ?? AppShadows.cardSm;

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double t = _controller.value * 2.0 * pi;
        final double translateY = sin(t) * widget.floatOffset;
        return Transform.translate(offset: Offset(0, translateY), child: child);
      },
      child: Container(
        constraints: BoxConstraints(
          maxWidth: size,
          maxHeight: size * widget.aspectRatio,
        ),
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? AppColors.surfaceContainerLow,
              gradient: widget.backgroundGradient,
              borderRadius: borderRadius,
              border: widget.border,
              boxShadow: effectiveShadows,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Center(
                  child: SizedBox(
                    width: widget.imageWidthFactor != null
                        ? double.infinity * widget.imageWidthFactor!
                        : null,
                    height: widget.imageHeightFactor != null
                        ? double.infinity * widget.imageHeightFactor!
                        : null,
                    child: Image.asset(
                      widget.imageAsset,
                      fit: widget.imageBoxFit,
                    ),
                  ),
                ),
                if (widget.enableGradientOverlay)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: _GradientOverlay(borderRadius: borderRadius),
                    ),
                  ),
                if (widget.overlayWidget != null)
                  Positioned.fill(
                    child: IgnorePointer(child: widget.overlayWidget!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientOverlay extends StatelessWidget {
  const _GradientOverlay({required this.borderRadius});

  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: <Color>[
            AppColors.primaryContainer.withValues(alpha: 0.10),
            Colors.transparent,
          ],
        ),
        backgroundBlendMode: BlendMode.overlay,
      ),
    );
  }
}
