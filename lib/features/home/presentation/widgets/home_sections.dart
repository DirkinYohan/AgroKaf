import 'package:flutter/material.dart';

import 'package:agrokaf/core/models/diagnosis_status.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/widgets/app_card.dart';

/// Section title with an optional trailing action.
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Semantics(
            header: true,
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

/// Quick stats in a 2x2 grid: total, healthy, phoma and other.
class StatsRow extends StatelessWidget {
  const StatsRow({
    super.key,
    required this.total,
    required this.healthy,
    required this.phoma,
    required this.other,
  });

  static const String totalLabel = 'Análisis';
  static const String healthyLabel = 'Sanas';
  static const String phomaLabel = 'Phoma';
  static const String otherLabel = 'Otras';

  final int total;
  final int healthy;
  final int phoma;
  final int other;

  @override
  Widget build(BuildContext context) {
    Widget row(Widget a, Widget b) => Row(
      children: <Widget>[
        Expanded(child: a),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: b),
      ],
    );
    _StatTile tile(int value, String label, DiagnosisStatus s) => _StatTile(
      value: value,
      label: label,
      icon: s.icon,
      color: s.color,
      background: s.containerColor,
    );
    return Column(
      children: <Widget>[
        row(
          _StatTile(
            value: total,
            label: totalLabel,
            icon: Icons.analytics_outlined,
            color: AppColors.secondary,
            background: AppColors.secondaryContainer,
          ),
          tile(healthy, healthyLabel, DiagnosisStatus.healthy),
        ),
        const SizedBox(height: AppSpacing.sm),
        row(
          tile(phoma, phomaLabel, DiagnosisStatus.phoma),
          tile(other, otherLabel, DiagnosisStatus.other),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });

  final int value;
  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs + 2),
              decoration: BoxDecoration(
                color: background,
                borderRadius: AppRadius.smAll,
              ),
              child: Icon(icon, color: color, size: AppSizes.iconSm),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('$value', style: textTheme.headlineSmall),
            Text(
              label,
              style: textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tips for taking a photo the model can analyze well.
class PhotoTipsCard extends StatelessWidget {
  const PhotoTipsCard({super.key});

  static const String _title = 'Consejos para una buena foto';
  static const List<(IconData, String)> _tips = <(IconData, String)>[
    (
      Icons.wb_sunny_outlined,
      'Usa luz natural, sin sombras fuertes ni sol directo.',
    ),
    (
      Icons.center_focus_strong_outlined,
      'Enfoca una sola hoja y que llene casi toda la foto.',
    ),
    (
      Icons.back_hand_outlined,
      'Mantén el celular quieto para que no salga borrosa.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return AppCard(
      color: AppColors.secondaryContainer,
      showBorder: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: AppColors.secondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _title,
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final (IconData icon, String tip) in _tips)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(icon, size: AppSizes.iconSm, color: AppColors.secondary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      tip,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
