import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'package:agrokaf/core/services/image_service.dart';

/// Implements the preprocessing contract of `model_info.json` exactly:
///
/// 1. decode the image and apply its EXIF orientation;
/// 2. convert to 8-bit RGB (drop alpha, expand palette/grayscale);
/// 3. resize the WHOLE image to [width] x [height] with BILINEAR
///    interpolation (stretch: no center crop, no letterbox);
/// 4. return a float32 NHWC tensor `[1, height, width, 3]` (flattened) with
///    RAW pixel values 0-255. No division by 255: the model normalizes
///    internally (MobileNetV3 `include_preprocessing=True`).
///
/// The resize reproduces TensorFlow's `tf.image.resize(method='bilinear')`
/// used in training (half-pixel centers, no antialiasing), so the app sees
/// the same pixels the model was trained on.
///
/// Pure and synchronous: run it in a background isolate.
class ImagePreprocessor {
  ImagePreprocessor._();

  static const int channels = 3;

  static Float32List preprocess(
    Uint8List encodedImage, {
    required int width,
    required int height,
  }) {
    final img.Image? decoded = img.decodeImage(encodedImage);
    if (decoded == null) throw const InvalidImageException();
    final img.Image oriented = img.bakeOrientation(decoded);
    final img.Image rgb = oriented.convert(
      format: img.Format.uint8,
      numChannels: channels,
    );
    return resizeBilinearToTensor(
      rgb.getBytes(order: img.ChannelOrder.rgb),
      srcWidth: rgb.width,
      srcHeight: rgb.height,
      dstWidth: width,
      dstHeight: height,
    );
  }

  /// Bilinear resize of interleaved RGB bytes into a float32 tensor.
  ///
  /// Mirrors TensorFlow's `compute_interpolation_weights` with
  /// `half_pixel_centers=True`: `in = (out + 0.5) * scale - 0.5`,
  /// `lower = max(floor(in), 0)`, `upper = min(ceil(in), size - 1)`,
  /// `lerp = in - floor(in)`.
  static Float32List resizeBilinearToTensor(
    Uint8List rgb, {
    required int srcWidth,
    required int srcHeight,
    required int dstWidth,
    required int dstHeight,
  }) {
    final Float32List out = Float32List(dstWidth * dstHeight * channels);
    final double scaleX = srcWidth / dstWidth;
    final double scaleY = srcHeight / dstHeight;

    final Int32List x0 = Int32List(dstWidth);
    final Int32List x1 = Int32List(dstWidth);
    final Float32List dx = Float32List(dstWidth);
    for (int x = 0; x < dstWidth; x++) {
      final double inX = (x + 0.5) * scaleX - 0.5;
      final double floorX = inX.floorToDouble();
      x0[x] = math.max(floorX.toInt(), 0);
      x1[x] = math.min(inX.ceil(), srcWidth - 1);
      dx[x] = inX - floorX;
    }

    int o = 0;
    for (int y = 0; y < dstHeight; y++) {
      final double inY = (y + 0.5) * scaleY - 0.5;
      final double floorY = inY.floorToDouble();
      final int y0 = math.max(floorY.toInt(), 0);
      final int y1 = math.min(inY.ceil(), srcHeight - 1);
      final double dy = inY - floorY;
      final int row0 = y0 * srcWidth;
      final int row1 = y1 * srcWidth;

      for (int x = 0; x < dstWidth; x++) {
        final int a = (row0 + x0[x]) * channels; // top-left
        final int b = (row0 + x1[x]) * channels; // top-right
        final int c = (row1 + x0[x]) * channels; // bottom-left
        final int d = (row1 + x1[x]) * channels; // bottom-right
        final double wx = dx[x];
        for (int ch = 0; ch < channels; ch++) {
          final double top = rgb[a + ch] + (rgb[b + ch] - rgb[a + ch]) * wx;
          final double bottom = rgb[c + ch] + (rgb[d + ch] - rgb[c + ch]) * wx;
          out[o++] = top + (bottom - top) * dy;
        }
      }
    }
    return out;
  }
}
