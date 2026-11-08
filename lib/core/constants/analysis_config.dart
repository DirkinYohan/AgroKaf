/// Tunable constants of the leaf analysis.
class AnalysisConfig {
  AnalysisConfig._();

  /// Bundled model files (see assets/model/README.md).
  static const String modelAsset = 'assets/model/model_fp16.tflite';
  static const String labelsAsset = 'assets/model/labels.txt';

  /// Below this top probability the result is "No concluyente".
  static const double confidenceThreshold = 0.70;

  /// CPU threads for inference.
  static const int inferenceThreads = 4;

  // Photo quality heuristics (computed on a <= 512 px grayscale copy).
  static const int qualityAnalysisMaxSide = 512;

  /// Mean luminance (0-255) below which the photo is "too dark".
  static const double minBrightness = 45;

  /// Mean luminance (0-255) above which the photo is "too bright".
  static const double maxBrightness = 215;

  /// Variance of the Laplacian below which the photo is "blurry".
  static const double minSharpness = 50;
}
