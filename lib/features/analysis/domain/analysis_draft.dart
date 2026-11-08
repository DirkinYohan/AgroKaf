import 'package:agrokaf/features/analysis/domain/classification_result.dart';

/// A finished but not yet saved analysis (passed from preview to result).
class AnalysisDraft {
  const AnalysisDraft({
    required this.imagePath,
    required this.result,
    required this.createdAt,
    this.modelVersion,
  });

  /// Sanitized photo in the private `analyses` folder.
  final String imagePath;
  final ClassificationResult result;
  final DateTime createdAt;
  final String? modelVersion;
}
