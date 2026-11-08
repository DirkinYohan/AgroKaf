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
}
