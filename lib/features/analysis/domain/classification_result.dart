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
  static const String phomaLabel = 'phoma';

  /// Softmax probability per label (labels.txt order is preserved).
  final Map<String, double> probabilities;
  final String topLabel;
  final double confidence;
  final DiagnosisStatus status;
  final int preprocessMs;
  final int inferenceMs;

  double get healthyProbability => probabilities[healthyLabel] ?? 0;
  double get phomaProbability => probabilities[phomaLabel] ?? 0;

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

    final DiagnosisStatus status;
    if (confidence < threshold) {
      status = DiagnosisStatus.inconclusive;
    } else if (topLabel == phomaLabel) {
      status = DiagnosisStatus.phoma;
    } else if (topLabel == healthyLabel) {
      status = DiagnosisStatus.healthy;
    } else {
      status = DiagnosisStatus.inconclusive;
    }

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
