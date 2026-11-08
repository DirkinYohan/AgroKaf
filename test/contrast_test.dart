import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agrokaf/core/theme/app_colors.dart';

/// WCAG 2.1 contrast ratio between two opaque colors.
double contrastRatio(Color a, Color b) {
  double channel(double c) =>
      c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  double luminance(Color c) =>
      0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
  final double la = luminance(a);
  final double lb = luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Every text/background pair used by the app must meet WCAG AA for normal
/// text (4.5:1). Farmers often use the app outdoors in bright sunlight.
void main() {
  const double aa = 4.5;
  final Map<String, (Color, Color)> pairs = <String, (Color, Color)>{
    'white on primary (buttons, analyze card)': (
      AppColors.onPrimary,
      AppColors.primary,
    ),
    'white on secondary': (AppColors.onSecondary, AppColors.secondary),
    'white on error (delete buttons)': (AppColors.onError, AppColors.error),
    'primary on background (text buttons, links)': (
      AppColors.primary,
      AppColors.background,
    ),
    'primary on surface': (AppColors.primary, AppColors.surface),
    'primary on primaryContainer (selected tab)': (
      AppColors.primary,
      AppColors.primaryContainer,
    ),
    'textPrimary on background': (AppColors.textPrimary, AppColors.background),
    'textSecondary on background': (
      AppColors.textSecondary,
      AppColors.background,
    ),
    'textMuted on background (captions)': (
      AppColors.textMuted,
      AppColors.background,
    ),
    'textMuted on surface (input hints)': (
      AppColors.textMuted,
      AppColors.surface,
    ),
    'textSecondary on surfaceMuted': (
      AppColors.textSecondary,
      AppColors.surfaceMuted,
    ),
    'healthy on healthyContainer': (
      AppColors.healthy,
      AppColors.healthyContainer,
    ),
    'phoma on phomaContainer': (AppColors.phoma, AppColors.phomaContainer),
    'inconclusive on inconclusiveContainer': (
      AppColors.inconclusive,
      AppColors.inconclusiveContainer,
    ),
    'onSecondaryContainer on secondaryContainer (tips, disclaimer)': (
      AppColors.onSecondaryContainer,
      AppColors.secondaryContainer,
    ),
    'onPrimaryContainer on healthyContainer (consent banner)': (
      AppColors.onPrimaryContainer,
      AppColors.healthyContainer,
    ),
    'error on surface (validation messages)': (
      AppColors.error,
      AppColors.surface,
    ),
    'surface on textPrimary (snackbars)': (
      AppColors.surface,
      AppColors.textPrimary,
    ),
  };

  for (final MapEntry<String, (Color, Color)> e in pairs.entries) {
    test('${e.key} >= $aa:1', () {
      final double ratio = contrastRatio(e.value.$1, e.value.$2);
      expect(
        ratio,
        greaterThanOrEqualTo(aa),
        reason: '${e.key}: ${ratio.toStringAsFixed(2)}:1',
      );
    });
  }
}
