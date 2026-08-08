import 'package:flutter/material.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';

class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.suffixIcon,
    this.onSuffixTap,
    this.readOnly = false,
    this.onTap,
    this.showCursor = true,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final String? Function(String? value)? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool showCursor;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final OutlineInputBorder enabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      borderSide: BorderSide(color: AppColors.outlineVariant),
    );
    final OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      borderSide: BorderSide(color: AppColors.primaryContainer, width: 2),
    );
    final OutlineInputBorder errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      borderSide: BorderSide(color: AppColors.error, width: 1.5),
    );
    final OutlineInputBorder focusedErrorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      borderSide: BorderSide(color: AppColors.error, width: 2),
    );

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      readOnly: readOnly,
      onTap: onTap,
      showCursor: readOnly ? false : showCursor,
      canRequestFocus: true,
      style:
          textTheme.bodyLarge?.copyWith(color: AppColors.onSurface) ??
          TextStyle(
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurface,
          ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.sm,
          ),
          child: Icon(icon, color: AppColors.onSurfaceVariant),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 36),
        labelText: label,
        hintText: hint,
        alignLabelWithHint: true,
        labelStyle:
            textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariant) ??
            TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
        hintStyle:
            textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.64),
            ) ??
            TextStyle(
              fontSize: 16,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.64),
            ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelStyle: TextStyle(
          color: AppColors.primaryContainer,
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
        suffixIcon: suffixIcon == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  onTap: onSuffixTap,
                  child: Icon(
                    suffixIcon,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
        suffixIconConstraints: const BoxConstraints(minWidth: 36),
        enabledBorder: enabledBorder,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: focusedErrorBorder,
        errorStyle:
            textTheme.bodyMedium?.copyWith(
              color: AppColors.error,
              height: 1.2,
            ) ??
            TextStyle(fontSize: 12, color: AppColors.error, height: 1.2),
      ),
    );
  }
}
