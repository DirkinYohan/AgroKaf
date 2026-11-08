import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'package:agrokaf/core/constants/analysis_config.dart';

enum PhotoQualityIssue { tooDark, tooBright, blurry }

/// Result of the quick photo check done before inference.
class PhotoQualityReport {
  const PhotoQualityReport({
    required this.brightness,
    required this.sharpness,
    required this.issues,
  });

  /// Mean luminance, 0-255.
  final double brightness;

  /// Variance of the Laplacian (higher = sharper).
  final double sharpness;
  final List<PhotoQualityIssue> issues;

  bool get isGood => issues.isEmpty;
}

/// Heuristic quality check: exposure (mean luminance) and blur (variance of
/// the Laplacian). Pure and synchronous: run it in a background isolate.
class PhotoQualityAnalyzer {
  PhotoQualityAnalyzer._();

  static PhotoQualityReport analyze(Uint8List encodedImage) {
    final img.Image? decoded = img.decodeImage(encodedImage);
    if (decoded == null) {
      return const PhotoQualityReport(
        brightness: 0,
        sharpness: 0,
        issues: <PhotoQualityIssue>[],
      );
    }
    img.Image image = img.bakeOrientation(decoded);
    final int longest = math.max(image.width, image.height);
    const int maxSide = AnalysisConfig.qualityAnalysisMaxSide;
    if (longest > maxSide) {
      image = image.width >= image.height
          ? img.copyResize(
              image,
              width: maxSide,
              interpolation: img.Interpolation.average,
            )
          : img.copyResize(
              image,
              height: maxSide,
              interpolation: img.Interpolation.average,
            );
    }
    final Float64List gray = _luminance(image);
    return evaluate(gray, image.width, image.height);
  }

  /// Scores a grayscale buffer (exposed for unit tests).
  static PhotoQualityReport evaluate(Float64List gray, int width, int height) {
    double sum = 0;
    for (final double v in gray) {
      sum += v;
    }
    final double brightness = gray.isEmpty ? 0 : sum / gray.length;
    final double sharpness = laplacianVariance(gray, width, height);

    return PhotoQualityReport(
      brightness: brightness,
      sharpness: sharpness,
      issues: <PhotoQualityIssue>[
        if (brightness < AnalysisConfig.minBrightness)
          PhotoQualityIssue.tooDark,
        if (brightness > AnalysisConfig.maxBrightness)
          PhotoQualityIssue.tooBright,
        if (sharpness < AnalysisConfig.minSharpness) PhotoQualityIssue.blurry,
      ],
    );
  }

  static Float64List _luminance(img.Image image) {
    final img.Image rgb = image.convert(
      format: img.Format.uint8,
      numChannels: 3,
    );
    final Uint8List bytes = rgb.getBytes(order: img.ChannelOrder.rgb);
    final Float64List gray = Float64List(rgb.width * rgb.height);
    for (int i = 0, p = 0; i < gray.length; i++, p += 3) {
      // ITU-R BT.601 luma.
      gray[i] = 0.299 * bytes[p] + 0.587 * bytes[p + 1] + 0.114 * bytes[p + 2];
    }
    return gray;
  }

  /// Variance of the 4-neighbour Laplacian. Low values mean few edges,
  /// i.e. a blurry photo.
  static double laplacianVariance(Float64List gray, int width, int height) {
    if (width < 3 || height < 3) return 0;
    double sum = 0;
    double sumSq = 0;
    int n = 0;
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        final int i = y * width + x;
        final double lap =
            gray[i - width] +
            gray[i + width] +
            gray[i - 1] +
            gray[i + 1] -
            4 * gray[i];
        sum += lap;
        sumSq += lap * lap;
        n++;
      }
    }
    final double mean = sum / n;
    return sumSq / n - mean * mean;
  }
}
