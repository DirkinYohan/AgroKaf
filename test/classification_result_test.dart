import 'package:flutter_test/flutter_test.dart';

import 'package:agrokaf/core/constants/analysis_config.dart';
import 'package:agrokaf/core/models/diagnosis_status.dart';
import 'package:agrokaf/features/analysis/domain/classification_result.dart';

void main() {
  ClassificationResult run(List<String> labels, List<double> output) =>
      ClassificationResult.fromOutput(
        labels: labels,
        output: output,
        preprocessMs: 0,
        inferenceMs: 0,
      );

  const List<String> labels = <String>['healthy', 'phoma'];

  test('confident phoma -> phoma', () {
    final ClassificationResult r = run(labels, <double>[0.08, 0.92]);
    expect(r.status, DiagnosisStatus.phoma);
    expect(r.confidence, closeTo(0.92, 1e-9));
    expect(r.phomaProbability, closeTo(0.92, 1e-9));
  });

  test('confident healthy -> healthy', () {
    expect(run(labels, <double>[0.97, 0.03]).status, DiagnosisStatus.healthy);
  });

  test(
    'top probability below ${AnalysisConfig.confidenceThreshold} -> inconclusive',
    () {
      expect(
        run(labels, <double>[0.45, 0.55]).status,
        DiagnosisStatus.inconclusive,
      );
      expect(
        run(labels, <double>[0.31, 0.69]).status,
        DiagnosisStatus.inconclusive,
      );
      expect(run(labels, <double>[0.30, 0.70]).status, DiagnosisStatus.phoma);
    },
  );

  test('labels are matched by name, not by position', () {
    final ClassificationResult r = run(
      <String>['phoma', 'healthy'],
      <double>[0.9, 0.1],
    );
    expect(r.status, DiagnosisStatus.phoma);
    expect(r.healthyProbability, closeTo(0.1, 1e-9));
  });

  test('mismatched label count is rejected', () {
    expect(() => run(labels, <double>[1.0]), throwsArgumentError);
  });

  group('3-class model (healthy, other, phoma)', () {
    const List<String> labels3 = <String>['healthy', 'other', 'phoma'];

    test('confident other -> other, with its probability', () {
      final ClassificationResult r = run(labels3, <double>[0.05, 0.9, 0.05]);
      expect(r.status, DiagnosisStatus.other);
      expect(r.otherProbability, closeTo(0.9, 1e-9));
    });

    test('confident phoma still -> phoma', () {
      expect(
        run(labels3, <double>[0.1, 0.1, 0.8]).status,
        DiagnosisStatus.phoma,
      );
    });

    test('below threshold -> inconclusive even if "other" is on top', () {
      expect(
        run(labels3, <double>[0.2, 0.5, 0.3]).status,
        DiagnosisStatus.inconclusive,
      );
    });

    test('2-class labels have no "other" probability', () {
      expect(run(labels, <double>[0.9, 0.1]).otherProbability, isNull);
    });
  });

  group('validateLabels', () {
    test('accepts the 2-class and 3-class models', () {
      expect(
        ClassificationResult.validateLabels(<String>['healthy', 'phoma']),
        isNull,
      );
      expect(
        ClassificationResult.validateLabels(<String>[
          'healthy',
          'other',
          'phoma',
        ]),
        isNull,
      );
    });

    test('rejects unknown, missing or duplicated class names', () {
      expect(
        ClassificationResult.validateLabels(<String>[
          'healthy',
          'phoma',
          'rust',
        ]),
        contains('rust'),
      );
      expect(
        ClassificationResult.validateLabels(<String>['healthy', 'other']),
        contains('phoma'),
      );
      expect(
        ClassificationResult.validateLabels(<String>[
          'healthy',
          'phoma',
          'phoma',
        ]),
        isNotNull,
      );
    });
  });
}
