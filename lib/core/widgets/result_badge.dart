import 'package:flutter/material.dart';

import 'package:agrokaf/core/models/diagnosis_status.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';

/// Pill showing a diagnosis result with icon + text (never color alone).
class ResultBadge extends StatelessWidget {
  const ResultBadge({super.key, required this.status, this.large = false});

  final DiagnosisStatus status;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Semantics(
      label: 'Resultado: ${status.label}',
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: large ? AppSpacing.md : AppSpacing.sm + AppSpacing.xs,
          vertical: large ? AppSpacing.sm : AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: status.containerColor,
          borderRadius: AppRadius.fullAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              status.icon,
              color: status.color,
              size: large ? AppSizes.iconMd : AppSizes.iconSm,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                status.label,
                overflow: TextOverflow.ellipsis,
                style: (large ? textTheme.labelLarge : textTheme.labelMedium)
                    ?.copyWith(color: status.color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
