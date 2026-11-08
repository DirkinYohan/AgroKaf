import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/utils/date_formatter.dart';
import 'package:agrokaf/core/widgets/app_button.dart';
import 'package:agrokaf/core/widgets/app_card.dart';
import 'package:agrokaf/core/widgets/state_views.dart';
import 'package:agrokaf/features/analysis/domain/analysis.dart';
import 'package:agrokaf/features/analysis/presentation/providers/analysis_providers.dart';
import 'package:agrokaf/features/analysis/presentation/widgets/analysis_widgets.dart';
import 'package:agrokaf/features/history/presentation/widgets/analysis_tile.dart';

/// Detail of one saved analysis.
class HistoryDetailPage extends ConsumerWidget {
  const HistoryDetailPage({super.key, required this.analysisId});

  final int analysisId;

  static const String title = 'Detalle del análisis';

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Analysis a,
  ) async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: const Text('¿Borrar este análisis?'),
            content: const Text(
              'Se borrarán el resultado y la foto. No se puede deshacer.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.onError,
                ),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Borrar'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !context.mounted) return;
    await ref.read(analysisRepositoryProvider).delete(a);
    ref.invalidate(analysesProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Análisis borrado')));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Analysis>> all = ref.watch(analysesProvider);
    final Analysis? analysis = all.value?.firstWhereOrNull(
      (Analysis a) => a.id == analysisId,
    );

    return Scaffold(
      appBar: AppBar(title: const Text(title)),
      body: all.isLoading && analysis == null
          ? const LoadingView()
          : analysis == null
          ? const EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Análisis no encontrado',
              message: 'Puede que ya lo hayas borrado.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              children: <Widget>[
                LeafPhoto(
                  image: FileImage(File(analysis.imagePath)),
                  heroTag: analysisHeroTag(analysis),
                  height: AppSizes.illustrationMax,
                ),
                const SizedBox(height: AppSpacing.md),
                DiagnosisCard(
                  status: analysis.status,
                  confidence: analysis.confidence,
                ),
                const SizedBox(height: AppSpacing.md),
                ProbabilitiesCard(
                  healthyProbability: analysis.healthyProbability,
                  phomaProbability: analysis.phomaProbability,
                ),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Column(
                    children: <Widget>[
                      DetailRow(
                        icon: Icons.event_outlined,
                        label: 'Fecha',
                        value: DateFormatter.dateTime(analysis.createdAt),
                      ),
                      if (analysis.lotName.isNotEmpty)
                        DetailRow(
                          icon: Icons.grid_view_outlined,
                          label: 'Lote',
                          value: analysis.lotName,
                        ),
                      if (analysis.note.isNotEmpty)
                        DetailRow(
                          icon: Icons.notes_outlined,
                          label: 'Nota',
                          value: analysis.note,
                        ),
                      DetailRow(
                        icon: Icons.timer_outlined,
                        label: 'Tiempo de análisis',
                        value: '${analysis.inferenceMs} ms',
                      ),
                      if (analysis.modelVersion != null)
                        DetailRow(
                          icon: Icons.memory_outlined,
                          label: 'Modelo',
                          value: analysis.modelVersion!,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const DisclaimerCard(),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Borrar este análisis',
                  icon: Icons.delete_outline_rounded,
                  variant: AppButtonVariant.text,
                  expand: true,
                  onPressed: () => _confirmDelete(context, ref, analysis),
                ),
              ],
            ),
    );
  }
}
