import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agrokaf/core/theme/app_spacing.dart';

/// Text input with its label ABOVE the field.
///
/// A static label (instead of a floating one) can never be clipped by parent
/// animations and is easier to read outdoors.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.icon,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.sentences,
    this.maxLength,
    this.isOptional = false,
    this.autofillHints,
    this.maxLines = 1,
  });

  final String label;
  final String? hint;
  final IconData? icon;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final bool isOptional;
  final Iterable<String>? autofillHints;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return FieldLabel(
      label: label,
      isOptional: isOptional,
      child: TextFormField(
        controller: controller,
        validator: validator,
        onChanged: onChanged,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        autofillHints: autofillHints,
        maxLength: maxLength,
        maxLines: maxLines,
        minLines: 1,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hint,
          counterText: '',
          prefixIcon: icon == null ? null : Icon(icon),
        ),
      ),
    );
  }
}

/// Dropdown with the same look and label placement as [AppTextField].
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.hint,
    this.icon,
    this.validator,
    this.isOptional = false,
  });

  final String label;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;
  final T? value;
  final String? hint;
  final IconData? icon;
  final FormFieldValidator<T>? validator;
  final bool isOptional;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return FieldLabel(
      label: label,
      isOptional: isOptional,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        validator: validator,
        onChanged: onChanged,
        borderRadius: AppRadius.mdAll,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        style: textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        hint: hint == null ? null : Text(hint!),
        decoration: InputDecoration(
          prefixIcon: icon == null ? null : Icon(icon),
        ),
        items: <DropdownMenuItem<T>>[
          for (final T item in items)
            DropdownMenuItem<T>(value: item, child: Text(itemLabel(item))),
        ],
      ),
    );
  }
}

/// Label + optional marker placed above a form control.
class FieldLabel extends StatelessWidget {
  const FieldLabel({
    super.key,
    required this.label,
    required this.child,
    this.isOptional = false,
  });

  static const String _optionalSuffix = ' (opcional)';

  final String label;
  final Widget child;
  final bool isOptional;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text.rich(
          TextSpan(
            text: label,
            style: textTheme.titleSmall,
            children: <InlineSpan>[
              if (isOptional)
                TextSpan(text: _optionalSuffix, style: textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}
