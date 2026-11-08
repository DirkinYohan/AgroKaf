import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agrokaf/core/constants/app_info.dart';
import 'package:agrokaf/core/models/model_info.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/widgets/app_card.dart';
import 'package:agrokaf/core/widgets/app_logo.dart';
import 'package:agrokaf/features/settings/presentation/providers/about_providers.dart';

/// "Acerca de": app and model versions, test metrics and thesis credits.
class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  static const String _title = 'Acerca de AgroKaf';
  static const String _description =
      'Detección temprana de la muerte descendente (Phoma) del café a partir '
      'de una foto de la hoja, 100 % sin internet.';
  static const String _disclaimer =
      'Esta herramienta es un apoyo y no reemplaza el diagnóstico de un '
      'técnico o agrónomo.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String appVersion = ref.watch(appVersionProvider).value ?? '…';
    final AsyncValue<ModelInfo?> model = ref.watch(modelInfoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(_title)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: <Widget>[
          const Center(child: AppLogo(height: AppSizes.logoSplash * 0.6)),
          const SizedBox(height: AppSpacing.md),
          Text(
            _description,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          _InfoCard(
            title: 'Aplicación',
            rows: <(String, String)>[('Versión', appVersion)],
          ),
          const SizedBox(height: AppSpacing.md),
          model.when(
            loading: () => const _InfoCard(
              title: 'Modelo de inteligencia artificial',
              rows: <(String, String)>[('Estado', 'Cargando…')],
            ),
            error: (_, _) => const _ModelUnavailable(),
            data: (ModelInfo? info) => info == null
                ? const _ModelUnavailable()
                : _ModelCard(info: info),
          ),
          const SizedBox(height: AppSpacing.md),
          const _InfoCard(
            title: 'Trabajo de grado',
            rows: <(String, String)>[
              ('Autor', AppInfo.author),
              ('Universidad', AppInfo.university),
              ('Región', AppInfo.region),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _disclaimer,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({required this.info});

  final ModelInfo info;

  static String _percent(double? v) =>
      v == null ? '—' : '${(v * 100).toStringAsFixed(1)} %';

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Modelo de inteligencia artificial',
      rows: <(String, String)>[
        ('Versión', info.version),
        ('Arquitectura', 'MobileNetV3Large (TFLite fp16)'),
        ('Clases', info.classNames.join(', ')),
        ('Exactitud (prueba)', _percent(info.testAccuracy)),
        ('Precisión macro', _percent(info.testMacroPrecision)),
        ('Sensibilidad macro', _percent(info.testMacroRecall)),
        ('F1 macro', _percent(info.testMacroF1)),
        if (info.testImages != null)
          ('Imágenes de prueba', '${info.testImages}'),
        if (info.tensorflowVersion != null)
          ('TensorFlow', info.tensorflowVersion!),
      ],
    );
  }
}

class _ModelUnavailable extends StatelessWidget {
  const _ModelUnavailable();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.inconclusiveContainer,
      showBorder: false,
      child: Row(
        children: <Widget>[
          const Icon(Icons.info_outline_rounded, color: AppColors.inconclusive),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Modelo no disponible: los archivos del modelo aún no están en '
              'la aplicación.',
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(title, style: textTheme.titleSmall),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final (String label, String value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: Text(label, style: textTheme.bodyMedium)),
                  const SizedBox(width: AppSpacing.md),
                  Flexible(
                    child: Text(
                      value,
                      textAlign: TextAlign.end,
                      style: textTheme.titleSmall,
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
