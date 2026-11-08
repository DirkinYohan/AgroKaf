import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agrokaf/core/theme/app_spacing.dart';

/// Subtle entrance: fades in while sliding up a few pixels.
///
/// [index] staggers items of a list. Disabled when the user asks the OS to
/// reduce animations.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({super.key, required this.child, this.index = 0});

  static const Duration _stagger = Duration(milliseconds: 60);
  static const int _maxStaggered = 8;

  final Widget child;
  final int index;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.slow,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  Timer? _delay;

  @override
  void initState() {
    super.initState();
    final int steps = widget.index.clamp(0, FadeSlideIn._maxStaggered);
    _delay = Timer(FadeSlideIn._stagger * steps, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _delay?.cancel();
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _delay?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(_curve),
        child: widget.child,
      ),
    );
  }
}
