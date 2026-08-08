import 'package:flutter/material.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';

class ProfileDropdownField extends StatelessWidget {
  const ProfileDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.items,
    this.value,
    this.validator,
    this.onChanged,
  });

  final String label;
  final String hint;
  final IconData icon;
  final List<String> items;
  final String? value;
  final String? Function(String? value)? validator;
  final ValueChanged<String?>? onChanged;

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

    return DropdownButtonFormField<String>(
      initialValue: (value?.isEmpty ?? true) ? null : value,
      validator: validator,
      onChanged: onChanged,
      icon: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.md),
        child: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      isExpanded: true,
      iconEnabledColor: AppColors.onSurfaceVariant,
      dropdownColor: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      elevation: 1,
      menuMaxHeight: 360,
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
        floatingLabelBehavior: FloatingLabelBehavior.auto,
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
        floatingLabelStyle: TextStyle(
          color: AppColors.primaryContainer,
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
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
      items: items
          .map<DropdownMenuItem<String>>(
            (String option) =>
                DropdownMenuItem<String>(value: option, child: Text(option)),
          )
          .toList(growable: false),
    );
  }
}
