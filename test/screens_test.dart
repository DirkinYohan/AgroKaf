import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:agrokaf/core/models/diagnosis_status.dart';
import 'package:agrokaf/core/providers/service_providers.dart';
import 'package:agrokaf/core/services/image_service.dart';
import 'package:agrokaf/core/theme/app_theme.dart';
import 'package:agrokaf/features/analysis/data/classifier_service.dart';
import 'package:agrokaf/features/analysis/domain/analysis.dart';
import 'package:agrokaf/features/analysis/domain/analysis_draft.dart';
import 'package:agrokaf/features/analysis/domain/classification_result.dart';
import 'package:agrokaf/features/analysis/presentation/pages/analysis_result_page.dart';
import 'package:agrokaf/features/analysis/presentation/providers/analysis_providers.dart';
import 'package:agrokaf/features/analysis/presentation/widgets/analysis_widgets.dart';
import 'package:agrokaf/features/history/presentation/pages/history_page.dart';
import 'package:agrokaf/features/home/presentation/pages/home_page.dart';
import 'package:agrokaf/features/profile/domain/entities/user_profile.dart';
import 'package:agrokaf/features/profile/presentation/providers/profile_providers.dart';

Analysis _analysis(int id, DiagnosisStatus status, {String lot = ''}) =>
    Analysis(
      id: id,
      imagePath: '/missing/$id.jpg',
      status: status,
      healthyProbability: status == DiagnosisStatus.healthy ? 0.95 : 0.05,
      phomaProbability: status == DiagnosisStatus.healthy ? 0.05 : 0.95,
      confidence: 0.95,
      inferenceMs: 80,
      createdAt: DateTime(2026, 11, 8, 10, id),
      lotName: lot,
    );

final List<Analysis> _history = <Analysis>[
  _analysis(3, DiagnosisStatus.phoma, lot: 'Lote alto'),
  _analysis(2, DiagnosisStatus.healthy),
  _analysis(1, DiagnosisStatus.inconclusive),
];

List<Override> _overrides({List<Analysis>? history}) => <Override>[
  profileProvider.overrideWith(
    (_) async => const UserProfile(userName: 'María Pérez'),
  ),
  analysesProvider.overrideWith((_) async => history ?? _history),
  modelStatusProvider.overrideWith((_) async => ModelStatus.ready),
];

Future<void> _pump(
  WidgetTester tester,
  Widget screen, {
  List<Override> overrides = const <Override>[],
  double textScale = 1,
}) async {
  tester.view.physicalSize = const Size(400, 860);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('es', 'CO'),
        supportedLocales: const <Locale>[Locale('es', 'CO')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        builder: (BuildContext context, Widget? child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _expectAccessible(WidgetTester tester) async {
  final SemanticsHandle handle = tester.ensureSemantics();
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  handle.dispose();
}

void main() {
  setUpAll(() => initializeDateFormatting('es_CO'));

  group('Inicio', () {
    testWidgets('greets the user and shows real stats and recent analyses', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const HomePage(), overrides: _overrides());
      expect(find.text('¡Hola, María!'), findsOneWidget);
      expect(find.text('Analiza una planta'), findsOneWidget);
      expect(find.text('Cámara'), findsOneWidget);
      expect(find.text('Galería'), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // total analyses
      expect(
        find.text(DiagnosisStatus.phoma.label),
        findsOneWidget,
      ); // recent tile
    });

    testWidgets('meets accessibility guidelines', (WidgetTester tester) async {
      await _pump(tester, const HomePage(), overrides: _overrides());
      await _expectAccessible(tester);
    });

    testWidgets('no overflow with 2x font size', (WidgetTester tester) async {
      await _pump(
        tester,
        const HomePage(),
        overrides: _overrides(),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('Historial', () {
    testWidgets('filters by result and searches by lot', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const HistoryPage(), overrides: _overrides());
      expect(find.text(DiagnosisStatus.healthy.label), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Phoma'));
      await tester.pumpAndSettle();
      expect(find.text(DiagnosisStatus.phoma.label), findsOneWidget);
      expect(find.text(DiagnosisStatus.healthy.label), findsNothing);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Todas'));
      await tester.enterText(find.byType(TextField), 'ALTO');
      await tester.pumpAndSettle();
      expect(find.text('Lote alto'), findsOneWidget);
      expect(find.text(DiagnosisStatus.inconclusive.label), findsNothing);
    });

    testWidgets('empty history shows the empty state', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const HistoryPage(),
        overrides: _overrides(history: const <Analysis>[]),
      );
      expect(find.text(HistoryPage.emptyTitle), findsOneWidget);
    });

    testWidgets('meets accessibility guidelines', (WidgetTester tester) async {
      await _pump(tester, const HistoryPage(), overrides: _overrides());
      await _expectAccessible(tester);
    });
  });

  group('Resultado', () {
    late Directory temp;
    late File photo;

    setUp(() {
      temp = Directory.systemTemp.createTempSync('agrokaf_result_');
      photo = File('${temp.path}/leaf.jpg')..writeAsBytesSync(<int>[0]);
    });
    tearDown(() {
      try {
        temp.deleteSync(recursive: true);
      } on FileSystemException {
        // Windows may still hold the image file open; the OS cleans temp.
      }
    });

    Widget resultFor(List<double> output) => AnalysisResultPage(
      draft: AnalysisDraft(
        imagePath: photo.path,
        createdAt: DateTime(2026, 11, 8, 9, 30),
        result: ClassificationResult.fromOutput(
          labels: const <String>['healthy', 'phoma'],
          output: output,
          preprocessMs: 30,
          inferenceMs: 95,
        ),
      ),
    );

    List<Override> resultOverrides() => <Override>[
      ..._overrides(),
      imageServiceProvider.overrideWithValue(
        ImageService(
          privateDirectory: () async => temp,
          temporaryDirectory: () async => temp,
        ),
      ),
    ];

    testWidgets('phoma result shows probabilities and the disclaimer', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        resultFor(<double>[0.08, 0.92]),
        overrides: resultOverrides(),
      );
      expect(find.text(DiagnosisStatus.phoma.title), findsOneWidget);
      expect(find.text('92.0 %'), findsWidgets);
      await tester.scrollUntilVisible(
        find.text(AnalysisResultPage.saveLabel),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(AnalysisResultPage.saveLabel), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text(DisclaimerCard.text),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(DisclaimerCard.text), findsOneWidget);
    });

    testWidgets('low confidence shows "No concluyente"', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        resultFor(<double>[0.4, 0.6]),
        overrides: resultOverrides(),
      );
      expect(find.text(DiagnosisStatus.inconclusive.title), findsOneWidget);
      expect(find.text(DiagnosisStatus.phoma.title), findsNothing);
    });

    testWidgets('meets accessibility guidelines', (WidgetTester tester) async {
      await _pump(
        tester,
        resultFor(<double>[0.95, 0.05]),
        overrides: resultOverrides(),
      );
      await _expectAccessible(tester);
    });
  });
}
