import 'package:flutter/material.dart';

import 'package:agrokaf/core/models/diagnosis_status.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/widgets/app_card.dart';
import 'package:agrokaf/core/widgets/confidence_bar.dart';

/// User-facing texts per diagnosis. Deliberately no treatments or agronomic
/// recommendations (out of the thesis scope).
extension DiagnosisTexts on DiagnosisStatus {
  String get title => switch (this) {
    DiagnosisStatus.healthy => 'Hoja sana',
    DiagnosisStatus.phoma => 'Posible muerte descendente',
    DiagnosisStatus.other => 'No corresponde a muerte descendente',
    DiagnosisStatus.inconclusive => 'Resultado no concluyente — toma otra foto',
  };

  String get message => switch (this) {
    DiagnosisStatus.healthy =>
      'No encontramos señales de muerte descendente (Phoma) en esta hoja.',
    DiagnosisStatus.phoma =>
      'La hoja muestra señales compatibles con muerte descendente (Phoma). '
          'Pide a un técnico o agrónomo que la revise para confirmarlo.',
    DiagnosisStatus.other =>
      'La hoja podría tener otra enfermedad o la imagen no es una hoja de '
          'café. Consulta a un técnico o agrónomo.',
    DiagnosisStatus.inconclusive =>
      'El modelo no está lo bastante seguro. Toma otra foto con buena luz, '
          'enfocando una sola hoja.',
  };
}

/// Big colored card with the diagnosis.
class DiagnosisCard extends StatelessWidget {
  const DiagnosisCard({
    super.key,
    required this.status,
    required this.confidence,
  });

  final DiagnosisStatus status;
  final double confidence;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: status.containerColor,
          borderRadius: AppRadius.xlAll,
          border: Border.all(color: status.color.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  status.icon,
                  color: status.color,
                  size: AppSizes.iconXl * 0.8,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    status.title,
                    style: textTheme.headlineSmall?.copyWith(
                      color: status.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              status.message,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            if (status != DiagnosisStatus.inconclusive) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              ConfidenceBar(
                label: 'Confianza',
                value: confidence,
                color: status.color,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Probability of each class. [otherProbability] is null for analyses made
/// with the 2-class model (v1); its bar is then not shown.
class ProbabilitiesCard extends StatelessWidget {
  const ProbabilitiesCard({
    super.key,
    required this.healthyProbability,
    required this.phomaProbability,
    this.otherProbability,
  });

  static const String healthyLabel = 'Sana';
  static const String phomaLabel = 'Muerte descendente (Phoma)';
  static const String otherLabel = 'Otra enfermedad o no es hoja de café';

  final double healthyProbability;
  final double phomaProbability;
  final double? otherProbability;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              'Probabilidad de cada resultado',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ConfidenceBar(
            label: healthyLabel,
            value: healthyProbability,
            color: DiagnosisStatus.healthy.color,
          ),
          const SizedBox(height: AppSpacing.md),
          ConfidenceBar(
            label: phomaLabel,
            value: phomaProbability,
            color: DiagnosisStatus.phoma.color,
          ),
          if (otherProbability != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            ConfidenceBar(
              label: otherLabel,
              value: otherProbability!,
              color: DiagnosisStatus.other.color,
            ),
          ],
        ],
      ),
    );
  }
}

/// Mandatory disclaimer shown with every result.
class DisclaimerCard extends StatelessWidget {
  const DisclaimerCard({super.key});

  static const String text =
      'Esta herramienta es un apoyo y no reemplaza el diagnóstico de un '
      'técnico o agrónomo.';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.info_outline_rounded, color: AppColors.secondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded photo of the analyzed leaf, shared through a Hero animation.
class LeafPhoto extends StatelessWidget {
  const LeafPhoto({super.key, required this.image, this.heroTag, this.height});

  final ImageProvider image;
  final Object? heroTag;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final Widget photo = ClipRRect(
      borderRadius: AppRadius.lgAll,
      child: Image(
        image: image,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        semanticLabel: 'Foto de la hoja analizada',
        errorBuilder: (_, _, _) => Container(
          height: height ?? AppSizes.illustrationMax,
          color: AppColors.surfaceVariant,
          child: const Icon(
            Icons.broken_image_outlined,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
    return heroTag == null ? photo : Hero(tag: heroTag!, child: photo);
  }
}

/// Small key/value row for technical details.
class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: AppSizes.iconSm, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: textTheme.bodyMedium)),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}
