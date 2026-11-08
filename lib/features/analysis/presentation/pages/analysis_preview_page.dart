import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:agrokaf/core/constants/app_routes.dart';
import 'package:agrokaf/core/providers/service_providers.dart';
import 'package:agrokaf/core/services/image_service.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/widgets/app_button.dart';
import 'package:agrokaf/core/widgets/app_card.dart';
import 'package:agrokaf/core/widgets/state_views.dart';
import 'package:agrokaf/features/analysis/data/classifier_service.dart';
import 'package:agrokaf/features/analysis/data/photo_quality_analyzer.dart';
import 'package:agrokaf/features/analysis/domain/analysis_draft.dart';
import 'package:agrokaf/features/analysis/domain/classification_result.dart';
import 'package:agrokaf/features/analysis/presentation/providers/analysis_providers.dart';
import 'package:agrokaf/features/analysis/presentation/widgets/analysis_widgets.dart';

enum _Stage { idle, preparing, analyzing }

/// Shows the picked photo, lets the user crop the leaf, checks the photo
/// quality and runs the model.
class AnalysisPreviewPage extends ConsumerStatefulWidget {
  const AnalysisPreviewPage({super.key, required this.sourcePath});

  final String sourcePath;

  static const String title = 'Revisa la foto';
  static const String analyzeLabel = 'Analizar';
  static const String analyzingMessage = 'Analizando la hoja…';

  @override
  ConsumerState<AnalysisPreviewPage> createState() =>
      _AnalysisPreviewPageState();
}

class _AnalysisPreviewPageState extends ConsumerState<AnalysisPreviewPage> {
  static const String _hint =
      'La hoja debe verse completa, nítida y llenar casi toda la foto. Si hay '
      'otras cosas alrededor, recórtala.';
  static const String _cropLabel = 'Recortar la hoja';
  static const String _otherLabel = 'Elegir otra foto';
  static const String _preparingMessage = 'Preparando la foto…';
  static const String _invalidImage =
      'No pudimos leer esa foto. Prueba con otra.';
  static const String _analysisError =
      'No pudimos analizar la foto. Inténtalo de nuevo.';

  late String _path = widget.sourcePath;
  _Stage _stage = _Stage.idle;

  bool get _busy => _stage != _Stage.idle;

  Future<void> _crop() async {
    final CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: _path,
      compressQuality: 95,
      uiSettings: <PlatformUiSettings>[
        AndroidUiSettings(
          toolbarTitle: _cropLabel,
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: AppColors.onPrimary,
          activeControlsWidgetColor: AppColors.primary,
          backgroundColor: AppColors.textPrimary,
          lockAspectRatio: false,
          initAspectRatio: CropAspectRatioPreset.original,
        ),
        IOSUiSettings(
          title: _cropLabel,
          doneButtonTitle: 'Listo',
          cancelButtonTitle: 'Cancelar',
        ),
      ],
    );
    if (cropped != null && mounted) setState(() => _path = cropped.path);
  }

  Future<void> _analyze() async {
    final ImageService images = ref.read(imageServiceProvider);
    final ClassifierService classifier = ref.read(classifierServiceProvider);
    String? workingPath;
    setState(() => _stage = _Stage.preparing);
    try {
      // 1. Private, metadata-free copy (also the one saved in the history).
      workingPath = await images.savePrivateImage(_path, ImageFolder.analyses);

      // 2. Quick quality check.
      final Uint8List bytes = await File(workingPath).readAsBytes();
      // Static helper: a closure created here would capture this State
      // (via the setState closures) and cannot be sent to an isolate.
      final PhotoQualityReport report =
          await PhotoQualityAnalyzer.analyzeInBackground(bytes);
      if (!report.isGood) {
        if (!mounted) return;
        setState(() => _stage = _Stage.idle);
        final bool proceed = await _showQualityWarning(report.issues);
        if (!proceed) {
          await images.deleteImage(workingPath);
          return;
        }
      }

      // 3. Inference (background isolates).
      if (!mounted) return;
      setState(() => _stage = _Stage.analyzing);
      final ClassificationResult result = await classifier.classify(
        workingPath,
      );
      await images.clearTemporaryFiles();
      if (!mounted) return;

      final String draftPath = workingPath;
      workingPath = null; // ownership moves to the result screen
      context.pushReplacement(
        AppRoutes.analysisResult,
        extra: AnalysisDraft(
          imagePath: draftPath,
          result: result,
          createdAt: DateTime.now(),
          modelVersion: classifier.info?.version,
        ),
      );
    } on InvalidImageException {
      await images.deleteImage(workingPath);
      _fail(_invalidImage);
    } catch (error, stack) {
      // Debug builds only: the message may contain file paths.
      if (kDebugMode) {
        debugPrint('AgroKaf analysis failed: $error');
        debugPrintStack(stackTrace: stack);
      }
      // Leaving the screen mid-analysis also lands here or returns early;
      // any photo left behind is removed at the next startup.
      await images.deleteImage(workingPath);
      _fail(_analysisError);
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() => _stage = _Stage.idle);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _showQualityWarning(List<PhotoQualityIssue> issues) async {
    String text(PhotoQualityIssue issue) => switch (issue) {
      PhotoQualityIssue.tooDark => 'La foto está muy oscura.',
      PhotoQualityIssue.tooBright => 'La foto tiene demasiada luz.',
      PhotoQualityIssue.blurry => 'La foto parece borrosa.',
    };
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            icon: const Icon(
              Icons.photo_filter_outlined,
              color: AppColors.inconclusive,
            ),
            title: const Text('Revisa la calidad de la foto'),
            content: Text(
              '${issues.map(text).join(' ')}\n\nUna foto mejor da un resultado '
              'más confiable.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Analizar así'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Tomar otra foto'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ModelStatus modelStatus =
        ref.watch(modelStatusProvider).value ?? ModelStatus.loading;
    final bool modelReady = modelStatus == ModelStatus.ready;

    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(title: const Text(AnalysisPreviewPage.title)),
        body: Stack(
          children: <Widget>[
            ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: <Widget>[
                LeafPhoto(
                  key: ValueKey<String>(_path),
                  image: FileImage(File(_path)),
                  height: AppSizes.illustrationMax * 1.3,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(_hint, style: textTheme.bodyMedium),
                if (modelStatus == ModelStatus.unavailable) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  const ModelUnavailableBanner(),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: AnalysisPreviewPage.analyzeLabel,
                  icon: Icons.biotech_outlined,
                  expand: true,
                  onPressed: modelReady && !_busy ? _analyze : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: _cropLabel,
                  icon: Icons.crop_rounded,
                  variant: AppButtonVariant.secondary,
                  expand: true,
                  onPressed: _busy ? null : _crop,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppButton(
                  label: _otherLabel,
                  variant: AppButtonVariant.text,
                  expand: true,
                  onPressed: _busy ? null : () => context.pop(),
                ),
              ],
            ),
            if (_busy)
              Positioned.fill(
                child: ColoredBox(
                  color: AppColors.background.withValues(alpha: 0.94),
                  child: LoadingView(
                    message: _stage == _Stage.preparing
                        ? _preparingMessage
                        : AnalysisPreviewPage.analyzingMessage,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the model files are missing from the app.
class ModelUnavailableBanner extends StatelessWidget {
  const ModelUnavailableBanner({super.key});

  static const String text =
      'Modelo no disponible: los archivos de inteligencia artificial no están '
      'en la aplicación, así que por ahora no se pueden analizar hojas.';

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.inconclusiveContainer,
      showBorder: false,
      child: Row(
        children: <Widget>[
          const Icon(Icons.cloud_off_outlined, color: AppColors.inconclusive),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.inconclusive),
            ),
          ),
        ],
      ),
    );
  }
}
