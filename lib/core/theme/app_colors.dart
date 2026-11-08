import 'package:flutter/material.dart';

/// Single source of truth for every color in the app.
///
/// Built from the AgroKaf logo: coffee-leaf green + coffee brown on warm,
/// soft neutrals. Screens must never hardcode colors: use these constants or
/// `Theme.of(context).colorScheme`.
///
/// Contrast notes (WCAG 2.1, normal text needs >= 4.5:1):
/// - white on [primary] ~ 7.9:1, white on [secondary] ~ 9.6:1
/// - [textPrimary] on [background] ~ 15:1, [textSecondary] ~ 8:1,
///   [textMuted] ~ 4.8:1
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF1B5E20);
  static const Color primaryPressed = Color(0xFF0F3D14);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFDCEFD8);
  static const Color onPrimaryContainer = Color(0xFF0F3D14);
  static const Color primarySoft = Color(0xFFA5D6A7);

  static const Color secondary = Color(0xFF5D4037);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFF1E4DD);
  static const Color onSecondaryContainer = Color(0xFF3E2723);

  // Neutrals (warm, never bluish)
  static const Color background = Color(0xFFFAFAF7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF3F4EF);
  static const Color surfaceVariant = Color(0xFFE8EBE4);
  static const Color illustrationBackground = Color(0xFFF7F6F1);

  static const Color textPrimary = Color(0xFF1C211C);
  static const Color textSecondary = Color(0xFF4A5348);
  static const Color textMuted = Color(0xFF636B60);

  static const Color outline = Color(0xFFC9CFC5);
  static const Color outlineStrong = Color(0xFF8A9386);

  // Feedback
  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFDECEA);
  static const Color onErrorContainer = Color(0xFF7A1A14);

  // Diagnosis results (foreground on its container >= 4.5:1)
  static const Color healthy = Color(0xFF1B5E20);
  static const Color healthyContainer = Color(0xFFE3F2E1);
  static const Color phoma = Color(0xFFB3261E);
  static const Color phomaContainer = Color(0xFFFDECEA);
  static const Color inconclusive = Color(0xFF7A4F00);
  static const Color inconclusiveContainer = Color(0xFFFFF2D6);

  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);
}
