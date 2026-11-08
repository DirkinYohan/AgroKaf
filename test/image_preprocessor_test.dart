import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:agrokaf/features/analysis/data/image_preprocessor.dart';

/// Tests of the preprocessing contract in assets/model/model_info.json.
void main() {
  group('resizeBilinearToTensor (TensorFlow half-pixel bilinear)', () {
    test('same size is the identity and keeps raw 0-255 values', () {
      final Uint8List rgb = Uint8List.fromList(<int>[0, 128, 255, 10, 20, 30]);
      final Float32List out = ImagePreprocessor.resizeBilinearToTensor(
        rgb,
        srcWidth: 2,
        srcHeight: 1,
        dstWidth: 2,
        dstHeight: 1,
      );
      expect(out, <double>[0, 128, 255, 10, 20, 30]);
    });

    test('2x2 -> 1x1 averages the four pixels (in = 0.5, lerp = 0.5)', () {
      final Uint8List rgb = Uint8List.fromList(<int>[
        0, 0, 0, 100, 0, 0, // row 0
        0, 200, 0, 100, 200, 40, // row 1
      ]);
      final Float32List out = ImagePreprocessor.resizeBilinearToTensor(
        rgb,
        srcWidth: 2,
        srcHeight: 2,
        dstWidth: 1,
        dstHeight: 1,
      );
      expect(out, <double>[50, 100, 10]);
    });

    test('upscaling clamps at the borders like TensorFlow', () {
      // 1D: [0, 100] -> 4 px. in = (x + .5) * .5 - .5 = -.25, .25, .75, 1.25
      // lower = max(floor,0), upper = min(ceil,1), lerp = in - floor(in)
      // x0: in=-.25 floor=-1 -> lower 0, upper 0 -> 0
      // x1: in=.25 -> 0 + 100*.25 = 25 ; x2: .75 -> 75 ; x3: 1.25 -> 100
      final Uint8List rgb = Uint8List.fromList(<int>[0, 0, 0, 100, 100, 100]);
      final Float32List out = ImagePreprocessor.resizeBilinearToTensor(
        rgb,
        srcWidth: 2,
        srcHeight: 1,
        dstWidth: 4,
        dstHeight: 1,
      );
      final List<double> red = <double>[for (int i = 0; i < 4; i++) out[i * 3]];
      expect(red, <double>[0, 25, 75, 100]);
    });
  });

  group('preprocess (full contract)', () {
    Uint8List png(img.Image image) => img.encodePng(image);

    test(
      'output is [1, 224, 224, 3] float32, RGB order, NOT divided by 255',
      () {
        final img.Image red = img.Image(width: 50, height: 30);
        img.fill(red, color: img.ColorRgb8(255, 0, 0));
        final Float32List t = ImagePreprocessor.preprocess(
          png(red),
          width: 224,
          height: 224,
        );
        expect(t.length, 224 * 224 * 3);
        expect(t.sublist(0, 3), <double>[255, 0, 0]);
        expect(t.reduce((double a, double b) => a > b ? a : b), 255);
      },
    );

    test('stretches the whole image (no center crop, no letterbox)', () {
      // Left half blue, right half green, 4:1 aspect ratio.
      final img.Image image = img.Image(width: 400, height: 100);
      img.fillRect(
        image,
        x1: 0,
        y1: 0,
        x2: 199,
        y2: 99,
        color: img.ColorRgb8(0, 0, 255),
      );
      img.fillRect(
        image,
        x1: 200,
        y1: 0,
        x2: 399,
        y2: 99,
        color: img.ColorRgb8(0, 255, 0),
      );
      final Float32List t = ImagePreprocessor.preprocess(
        png(image),
        width: 224,
        height: 224,
      );
      List<double> pixel(int x, int y) {
        final int i = (y * 224 + x) * 3;
        return <double>[t[i], t[i + 1], t[i + 2]];
      }

      // A crop would lose one color; a letterbox would add black bars.
      expect(pixel(0, 0), <double>[0, 0, 255]);
      expect(pixel(223, 223), <double>[0, 255, 0]);
      expect(pixel(0, 112), <double>[0, 0, 255]);
    });

    test('drops the alpha channel', () {
      final img.Image rgba = img.Image(width: 8, height: 8, numChannels: 4);
      img.fill(rgba, color: img.ColorRgba8(10, 20, 30, 0));
      final Float32List t = ImagePreprocessor.preprocess(
        png(rgba),
        width: 4,
        height: 4,
      );
      expect(t.length, 4 * 4 * 3);
      expect(t.sublist(0, 3), <double>[10, 20, 30]);
    });
  });
}
