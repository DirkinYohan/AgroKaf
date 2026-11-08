import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agrokaf/core/constants/app_routes.dart';
import 'package:agrokaf/core/providers/service_providers.dart';
import 'package:agrokaf/core/services/image_service.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/utils/date_formatter.dart';
import 'package:agrokaf/core/widgets/app_button.dart';
import 'package:agrokaf/core/widgets/app_card.dart';
import 'package:agrokaf/core/widgets/app_text_field.dart';
import 'package:agrokaf/core/widgets/fade_slide_in.dart';
import 'package:agrokaf/features/analysis/domain/analysis.dart';
import 'package:agrokaf/features/analysis/domain/analysis_draft.dart';
import 'package:agrokaf/features/analysis/domain/classification_result.dart';
import 'package:agrokaf/features/analysis/presentation/analysis_launcher.dart';
import 'package:agrokaf/features/analysis/presentation/providers/analysis_providers.dart';
import 'package:agrokaf/features/analysis/presentation/widgets/analysis_widgets.dart';

/// Result of an analysis, with the option to save it in the history.
class AnalysisResultPage extends ConsumerStatefulWidget {
  const AnalysisResultPage({super.key, required this.draft});

  final AnalysisDraft draft;

  static const String title = 'Resultado';
  static const String saveLabel = 'Guardar en historial';
  static const String savedLabel = 'Guardado en tu historial';
  static const String analyzeAnotherLabel = 'Analizar otra';

  @override
  ConsumerState<AnalysisResultPage> createState() => _AnalysisResultPageState();
}

class _AnalysisResultPageState extends ConsumerState<AnalysisResultPage> {
  static const String _lotLabel = 'Lote o parcela';
  static const String _lotHint = 'Ej.: Lote 3, junto a la quebrada';
  static const String _noteLabel = 'Nota';
  static const String _noteHint = 'Ej.: hojas secas en la parte alta';
  static const String _saveError =
      'No pudimos guardar el análisis. Inténtalo de nuevo.';

  final TextEditingController _lotController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  late final ImageService _images;
  Analysis? _saved;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _images = ref.read(imageServiceProvider);
  }

  ClassificationResult get _result => widget.draft.result;

  @override
  void dispose() {
    _lotController.dispose();
    _noteController.dispose();
    // Not saved: the photo must not stay on the device.
    if (_saved == null) {
      _images.deleteImage(widget.draft.imagePath);
    }
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    try {
      final Analysis saved = await ref
          .read(analysisRepositoryProvider)
          .insert(
            Analysis(
              imagePath: widget.draft.imagePath,
              status: _result.status,
              healthyProbability: _result.healthyProbability,
              phomaProbability: _result.phomaProbability,
              confidence: _result.confidence,
              inferenceMs: _result.inferenceMs,
              modelVersion: widget.draft.modelVersion,
              lotName: _lotController.text,
              note: _noteController.text,
              createdAt: widget.draft.createdAt,
            ),
          );
      ref.invalidate(analysesProvider);
      if (!mounted) return;
      setState(() {
        _saved = saved;
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AnalysisResultPage.savedLabel)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(_saveError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool saved = _saved != null;
    return Scaffold(
      appBar: AppBar(title: const Text(AnalysisResultPage.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        children: <Widget>[
          FadeSlideIn(
            child: DiagnosisCard(
              status: _result.status,
              confidence: _result.confidence,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LeafPhoto(
            image: FileImage(File(widget.draft.imagePath)),
            height: AppSizes.illustrationMax,
          ),
          const SizedBox(height: AppSpacing.md),
          ProbabilitiesCard(
            healthyProbability: _result.healthyProbability,
            phomaProbability: _result.phomaProbability,
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              children: <Widget>[
                DetailRow(
                  icon: Icons.event_outlined,
                  label: 'Fecha',
                  value: DateFormatter.dateTime(widget.draft.createdAt),
                ),
                DetailRow(
                  icon: Icons.timer_outlined,
                  label: 'Tiempo de análisis',
                  value: '${_result.inferenceMs} ms',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (!saved) ...<Widget>[
            AppTextField(
              label: _lotLabel,
              hint: _lotHint,
              icon: Icons.grid_view_outlined,
              controller: _lotController,
              isOptional: true,
              maxLength: Analysis.lotMaxLength,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: _noteLabel,
              hint: _noteHint,
              icon: Icons.notes_outlined,
              controller: _noteController,
              isOptional: true,
              maxLines: 3,
              maxLength: Analysis.noteMaxLength,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          AnimatedSwitcher(
            duration: AppDurations.medium,
            child: saved
                ? AppButton(
                    key: const ValueKey<String>('view'),
                    label: 'Ver en el historial',
                    icon: Icons.history_rounded,
                    variant: AppButtonVariant.secondary,
                    expand: true,
                    onPressed: () => context.go(AppRoutes.history),
                  )
                : AppButton(
                    key: const ValueKey<String>('save'),
                    label: AnalysisResultPage.saveLabel,
                    icon: Icons.save_outlined,
                    isLoading: _isSaving,
                    expand: true,
                    onPressed: _save,
                  ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: AnalysisResultPage.analyzeAnotherLabel,
            icon: Icons.add_a_photo_outlined,
            variant: saved
                ? AppButtonVariant.primary
                : AppButtonVariant.secondary,
            expand: true,
            onPressed: _isSaving
                ? null
                : () =>
                      chooseSourceAndStartAnalysis(context, ref, replace: true),
          ),
          const SizedBox(height: AppSpacing.lg),
          const DisclaimerCard(),
        ],
      ),
    );
  }
}
