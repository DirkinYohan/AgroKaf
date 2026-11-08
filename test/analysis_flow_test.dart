import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;

import 'package:agrokaf/core/constants/analysis_config.dart';
import 'package:agrokaf/core/constants/app_routes.dart';
import 'package:agrokaf/core/providers/service_providers.dart';
import 'package:agrokaf/core/services/image_service.dart';
import 'package:agrokaf/core/theme/app_theme.dart';
import 'package:agrokaf/features/analysis/data/classifier_service.dart';
import 'package:agrokaf/features/analysis/domain/analysis_draft.dart';
import 'package:agrokaf/features/analysis/presentation/pages/analysis_preview_page.dart';
import 'package:agrokaf/features/analysis/presentation/providers/analysis_providers.dart';

/// Regression test: tapping "Analizar" on the real preview screen must reach
/// the result screen (real ImageService, isolates and LiteRT model).
void main() {
  final bool hasModel = File(AnalysisConfig.modelAsset).existsSync();

  testWidgets('Analizar goes from the preview to the result', (
    WidgetTester tester,
  ) async {
    final Directory temp = Directory.systemTemp.createTempSync('agrokaf_flow_');
    final Directory private = Directory('${temp.path}/private')..createSync();
    final Directory cache = Directory('${temp.path}/cache')..createSync();
    final img.Image photo = img.Image(width: 800, height: 600);
    for (int y = 0; y < photo.height; y++) {
      for (int x = 0; x < photo.width; x++) {
        photo.setPixelRgb(
          x,
          y,
          40 + (x * 7 + y * 3) % 120,
          120 + (x ^ y) % 90,
          40,
        );
      }
    }
    final File picked = File('${cache.path}/picked.jpg')
      ..writeAsBytesSync(img.encodeJpg(photo));

    final ClassifierService classifier = ClassifierService();
    await tester.runAsync(classifier.load);
    if (!classifier.isReady) {
      markTestSkipped('model not loadable: ${classifier.unavailableReason}');
      return;
    }

    AnalysisDraft? received;
    final GoRouter router = GoRouter(
      initialLocation: AppRoutes.analysisPreview,
      initialExtra: picked.path,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.analysisPreview,
          builder: (_, GoRouterState s) =>
              AnalysisPreviewPage(sourcePath: s.extra! as String),
        ),
        GoRoute(
          path: AppRoutes.analysisResult,
          builder: (_, GoRouterState s) {
            received = s.extra! as AnalysisDraft;
            return const Scaffold(body: Text('RESULT'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          imageServiceProvider.overrideWithValue(
            ImageService(
              privateDirectory: () async => private,
              temporaryDirectory: () async => cache,
            ),
          ),
          classifierServiceProvider.overrideWithValue(classifier),
          modelStatusProvider.overrideWith((_) async => ModelStatus.ready),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light(),
          locale: const Locale('es', 'CO'),
          supportedLocales: const <Locale>[Locale('es', 'CO')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(AnalysisPreviewPage.analyzeLabel));
    await tester.pump();

    // Let the real isolates and file I/O finish.
    for (int i = 0; i < 40 && received == null; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 250)),
      );
      await tester.pump();
      if (find.byType(AlertDialog).evaluate().isNotEmpty) {
        await tester.tap(find.text('Analizar así')); // quality warning
        await tester.pump();
      }
    }

    expect(find.textContaining('No pudimos'), findsNothing);
    expect(received, isNotNull, reason: 'never reached the result screen');
    expect(
      received!.result.healthyProbability + received!.result.phomaProbability,
      closeTo(1, 1e-3),
    );

    await tester.runAsync(classifier.dispose);
    try {
      temp.deleteSync(recursive: true);
    } on FileSystemException {
      // Windows may keep files locked briefly.
    }
  }, skip: !hasModel);
}
