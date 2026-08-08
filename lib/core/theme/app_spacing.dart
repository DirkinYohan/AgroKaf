import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const double gutter = 16.0;
  static const double marginMobile = 16.0;
  static const double marginDesktop = 64.0;

  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radius2xl = 24.0;
  static const double radiusFull = 9999.0;

  static const double dotSize = 12.0;
  static const double paginationDotActive = 10.0;
  static const double paginationDotInactive = 8.0;
  static const double paginationGap = 8.0;
  static const double logoSizeMobile = 288.0;
  static const double logoSizeTablet = 320.0;
  static const double illustrationMaxSize = 320.0;

  static const double tabletBreakpoint = 600.0;
}

class AppAnimations {
  AppAnimations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 800);
  static const Duration fadeInUp = Duration(milliseconds: 1000);
  static const Duration bounceDot = Duration(milliseconds: 1400);
  static const Duration float = Duration(seconds: 6);
  static const Duration paginationDot = Duration(milliseconds: 300);
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get logoContainer => [
    BoxShadow(
      color: const Color(0xFF1B5E20).withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get cardSm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get buttonSm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
}
