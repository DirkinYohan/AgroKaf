import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:agrokaf/core/models/diagnosis_status.dart';
import 'package:agrokaf/features/analysis/data/photo_quality_analyzer.dart';
import 'package:agrokaf/features/analysis/domain/analysis.dart';
import 'package:agrokaf/features/history/domain/history_filter.dart';

void main() {
  group('PhotoQualityAnalyzer.evaluate', () {
    const int w = 64;
    const int h = 64;
    Float64List uniform(double v) => Float64List(w * h)..fillRange(0, w * h, v);
    Float64List checkerboard() => Float64List.fromList(<double>[
      for (int y = 0; y < h; y++)
        for (int x = 0; x < w; x++) ((x ~/ 4 + y ~/ 4).isEven ? 40.0 : 210.0),
    ]);

    test('flat image is blurry', () {
      expect(
        PhotoQualityAnalyzer.evaluate(uniform(120), w, h).issues,
        <PhotoQualityIssue>[PhotoQualityIssue.blurry],
      );
    });

    test('dark and bright images are detected', () {
      expect(
        PhotoQualityAnalyzer.evaluate(uniform(10), w, h).issues,
        contains(PhotoQualityIssue.tooDark),
      );
      expect(
        PhotoQualityAnalyzer.evaluate(uniform(250), w, h).issues,
        contains(PhotoQualityIssue.tooBright),
      );
    });

    test('sharp, well exposed image passes', () {
      final PhotoQualityReport r = PhotoQualityAnalyzer.evaluate(
        checkerboard(),
        w,
        h,
      );
      expect(
        r.isGood,
        isTrue,
        reason: 'brightness ${r.brightness}, sharpness ${r.sharpness}',
      );
    });
  });

  group('filterAnalyses', () {
    Analysis a(DiagnosisStatus s, {String note = '', String lot = ''}) =>
        Analysis(
          imagePath: '/x.jpg',
          status: s,
          healthyProbability: 0.5,
          phomaProbability: 0.5,
          confidence: 0.5,
          inferenceMs: 1,
          createdAt: DateTime(2026),
          note: note,
          lotName: lot,
        );

    final List<Analysis> all = <Analysis>[
      a(DiagnosisStatus.healthy, lot: 'Lote Café Alto'),
      a(DiagnosisStatus.phoma, note: 'Hojas secas'),
      a(DiagnosisStatus.inconclusive),
    ];

    test('filters by status', () {
      expect(
        filterAnalyses(all, filter: HistoryFilter.phoma).single.status,
        DiagnosisStatus.phoma,
      );
      expect(filterAnalyses(all).length, 3);
    });

    test('search ignores case and accents in note and lot', () {
      expect(
        filterAnalyses(all, query: 'cafe').single.lotName,
        'Lote Café Alto',
      );
      expect(
        filterAnalyses(all, query: 'SECAS').single.status,
        DiagnosisStatus.phoma,
      );
      expect(filterAnalyses(all, query: 'nada'), isEmpty);
    });
  });

  test('"Otras" filter shows only analyses classified as other', () {
    final Analysis other = Analysis(
      imagePath: '/o.jpg',
      status: DiagnosisStatus.other,
      healthyProbability: 0.05,
      phomaProbability: 0.05,
      otherProbability: 0.9,
      confidence: 0.9,
      inferenceMs: 1,
      createdAt: DateTime(2026),
    );
    final Analysis healthy = Analysis(
      imagePath: '/h.jpg',
      status: DiagnosisStatus.healthy,
      healthyProbability: 0.9,
      phomaProbability: 0.1,
      confidence: 0.9,
      inferenceMs: 1,
      createdAt: DateTime(2026),
    );
    expect(
      filterAnalyses(<Analysis>[other, healthy], filter: HistoryFilter.other),
      <Analysis>[other],
    );
    expect(HistoryFilter.values.map((HistoryFilter f) => f.label), <String>[
      'Todas',
      'Sanas',
      'Phoma',
      'Otras',
      'No concluyentes',
    ]);
    expect(AnalysisStats.of(<Analysis>[other, healthy]).other, 1);
  });
}
