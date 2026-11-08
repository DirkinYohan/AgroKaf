import 'package:agrokaf/core/constants/analysis_config.dart';
import 'package:agrokaf/core/models/diagnosis_status.dart';

/// Output of one inference, already interpreted.
class ClassificationResult {
  const ClassificationResult({
    required this.probabilities,
    required this.topLabel,
    required this.confidence,
    required this.status,
    required this.preprocessMs,
    required this.inferenceMs,
  });

  static const String healthyLabel = 'healthy';
  static const String otherLabel = 'other';
  static const String phomaLabel = 'phoma';

  /// Class names the app understands. `other` is optional (the 2-class v1
  /// model has no rejection class); `healthy` and `phoma` are required.
  static const Set<String> knownLabels = <String>{
    healthyLabel,
    otherLabel,
    phomaLabel,
  };
  static const Set<String> requiredLabels = <String>{healthyLabel, phomaLabel};

  /// Returns a problem description if [labels] cannot be used, else null.
  static String? validateLabels(List<String> labels) {
    final Set<String> unknown = labels.toSet().difference(knownLabels);
    if (unknown.isNotEmpty) {
      return 'unknown class name(s) in labels.txt: ${unknown.join(', ')}';
    }
    final Set<String> missing = requiredLabels.difference(labels.toSet());
    if (missing.isNotEmpty) {
      return 'missing class name(s) in labels.txt: ${missing.join(', ')}';
    }
    if (labels.toSet().length != labels.length) {
      return 'duplicated class names in labels.txt';
    }
    return null;
  }

  /// Softmax probability per label (labels.txt order is preserved).
  final Map<String, double> probabilities;
  final String topLabel;
  final double confidence;
  final DiagnosisStatus status;
  final int preprocessMs;
  final int inferenceMs;

  double get healthyProbability => probabilities[healthyLabel] ?? 0;
  double get phomaProbability => probabilities[phomaLabel] ?? 0;

  /// Null when the model has no `other` class.
  double? get otherProbability => probabilities[otherLabel];

  /// Maps the model output to a diagnosis. Labels are matched by NAME, never
  /// by index, so a different label order cannot swap the result.
  factory ClassificationResult.fromOutput({
    required List<String> labels,
    required List<double> output,
    required int preprocessMs,
    required int inferenceMs,
    double threshold = AnalysisConfig.confidenceThreshold,
  }) {
    if (labels.length != output.length) {
      throw ArgumentError(
        'labels (${labels.length}) and output (${output.length}) differ',
      );
    }
    final Map<String, double> probabilities = <String, double>{
      for (int i = 0; i < labels.length; i++) labels[i]: output[i],
    };
    int top = 0;
    for (int i = 1; i < output.length; i++) {
      if (output[i] > output[top]) top = i;
    }
    final String topLabel = labels[top];
    final double confidence = output[top];

    final DiagnosisStatus status = confidence < threshold
        ? DiagnosisStatus.inconclusive
        : switch (topLabel) {
            phomaLabel => DiagnosisStatus.phoma,
            healthyLabel => DiagnosisStatus.healthy,
            otherLabel => DiagnosisStatus.other,
            _ => DiagnosisStatus.inconclusive,
          };

    return ClassificationResult(
      probabilities: probabilities,
      topLabel: topLabel,
      confidence: confidence,
      status: status,
      preprocessMs: preprocessMs,
      inferenceMs: inferenceMs,
    );
  }
}
