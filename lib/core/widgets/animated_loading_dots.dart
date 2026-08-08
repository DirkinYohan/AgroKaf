import 'package:flutter/material.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';

class AnimatedLoadingDots extends StatefulWidget {
  const AnimatedLoadingDots({
    super.key,
    this.color,
    this.dotSize,
    this.spacing,
    this.duration = AppAnimations.bounceDot,
  });

  final Color? color;
  final double? dotSize;
  final double? spacing;
  final Duration duration;

  @override
  State<AnimatedLoadingDots> createState() => _AnimatedLoadingDotsState();
}

class _AnimatedLoadingDotsState extends State<AnimatedLoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<double> _startDelays = <double>[0.32, 0.16, 0.0];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.dotSize ?? AppSpacing.dotSize;
    final double space = widget.spacing ?? AppSpacing.sm;
    final Color dotColor = widget.color ?? AppColors.primaryContainer;

    return SizedBox(
      height: AppSpacing.xl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < _startDelays.length; i++)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: space / 2),
              child: _buildDot(i, size, dotColor),
            ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, double size, Color color) {
    final double total = widget.duration.inMilliseconds.toDouble();
    final double start = _startDelays[index] * 1000 / total;
    const double active = 0.4;
    const double idle = 0.2;
    final double endInterval = (start + active + idle).clamp(0.0, 1.0);

    final Animation<double> scale =
        TweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(
              begin: 0,
              end: 1,
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: (active / 2) * 100,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(
              begin: 1,
              end: 0,
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: (active / 2) * 100,
          ),
          TweenSequenceItem<double>(
            tween: ConstantTween<double>(0),
            weight: (1 - active) * 100,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, endInterval, curve: Curves.linear),
          ),
        );

    return ScaleTransition(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
