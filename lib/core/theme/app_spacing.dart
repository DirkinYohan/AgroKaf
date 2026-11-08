import 'package:flutter/material.dart';

import 'package:agrokaf/core/theme/app_colors.dart';

/// Spacing scale (4 / 8 / 16 / 24 / 32 / 48).
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Horizontal padding of every screen.
  static const double screen = md;
}

/// Corner radius scale.
class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));
}

/// Fixed component sizes.
class AppSizes {
  AppSizes._();

  /// Minimum touch target (Material / WCAG guidance).
  static const double minTouchTarget = 48;
  static const double buttonHeight = 56;

  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 56;

  static const double avatarSm = 48;
  static const double avatarLg = 112;

  static const double logoSplash = 200;
  static const double logoHeader = 64;

  static const double illustrationMax = 300;
  static const double contentMaxWidth = 560;

  static const double indicatorDot = 8;
  static const double indicatorActiveWidth = 24;
  static const double confidenceBarHeight = 12;
  static const double loadingDot = 12;
  static const double sheetHandleWidth = 40;
  static const double sheetHandleHeight = 4;
}

/// Animation durations.
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration entrance = Duration(milliseconds: 800);
  static const Duration loadingDots = Duration(milliseconds: 1400);
  static const Duration float = Duration(seconds: 6);
  static const Duration splashMinimum = Duration(milliseconds: 2200);
}

/// Elevation shadows (soft, low contrast).
class AppShadows {
  AppShadows._();

  static final List<BoxShadow> card = <BoxShadow>[
    BoxShadow(
      color: AppColors.shadow.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> elevated = <BoxShadow>[
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}
