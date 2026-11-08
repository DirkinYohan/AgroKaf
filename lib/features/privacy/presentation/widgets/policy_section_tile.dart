import 'package:flutter/material.dart';

import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/features/privacy/domain/privacy_policy.dart';

/// Icon + title + body block used by the consent and policy screens.
class PolicySectionTile extends StatelessWidget {
  const PolicySectionTile({super.key, required this.section});

  final PolicySection section;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: const BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: AppRadius.mdAll,
          ),
          child: Icon(
            section.icon,
            color: AppColors.primary,
            size: AppSizes.iconMd,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(section.title, style: textTheme.titleSmall),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(section.body, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
