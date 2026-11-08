import 'package:flutter/material.dart';

import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';

enum AppButtonVariant {
  /// Filled green button with white text (main action of a screen).
  primary,

  /// Outlined green button (secondary action).
  secondary,

  /// Text-only button (tertiary action: "Omitir", "Atrás").
  text,

  /// White button with green text, for use on top of green surfaces.
  inverse,
}

/// The only button used across the app. Always >= 48 dp tall.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.trailingIcon = false,
    this.isLoading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;

  /// Places [icon] after the label (e.g. an arrow on "Siguiente").
  final bool trailingIcon;
  final bool isLoading;

  /// Stretches the button to the available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? effectiveOnPressed = isLoading ? null : onPressed;
    final Widget child = _ButtonContent(
      label: label,
      icon: icon,
      trailingIcon: trailingIcon,
      isLoading: isLoading,
      loaderColor: variant == AppButtonVariant.primary
          ? AppColors.onPrimary
          : AppColors.primary,
    );

    final Widget button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      AppButtonVariant.inverse => FilledButton(
        onPressed: effectiveOnPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.primary,
        ),
        child: child,
      ),
    };

    return Semantics(
      button: true,
      enabled: effectiveOnPressed != null,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.trailingIcon,
    required this.isLoading,
    required this.loaderColor,
  });

  final String label;
  final IconData? icon;
  final bool trailingIcon;
  final bool isLoading;
  final Color loaderColor;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox.square(
        dimension: AppSizes.iconSm,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: loaderColor),
      );
    }
    final Widget label = Text(
      this.label,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
    if (icon == null) return label;
    final Widget text = Flexible(child: label);
    final Widget iconWidget = Icon(icon, size: AppSizes.iconSm);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: trailingIcon
          ? <Widget>[text, const SizedBox(width: AppSpacing.sm), iconWidget]
          : <Widget>[iconWidget, const SizedBox(width: AppSpacing.sm), text],
    );
  }
}
