import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:agrokaf/core/theme/app_colors.dart';

class SplashBackgroundDecorations extends StatelessWidget {
  const SplashBackgroundDecorations({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.20,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: const Alignment(1.2, -1.2),
                child: _buildBlurCircle(
                  color: AppColors.primaryContainer,
                  sizeFactor: 0.60,
                  sigma: 100,
                ),
              ),
              Align(
                alignment: const Alignment(-1.2, 1.2),
                child: _buildBlurCircle(
                  color: AppColors.surfaceVariant,
                  sizeFactor: 0.80,
                  sigma: 120,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlurCircle({
    required Color color,
    required double sizeFactor,
    required double sigma,
  }) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxSide = constraints.biggest.longestSide;
        final double size = maxSide * sizeFactor;
        return ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
