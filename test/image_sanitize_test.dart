import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:agrokaf/core/services/image_service.dart';

void main() {
  group('ImageService.sanitizeImage', () {
    Uint8List jpegWithGps({required int width, required int height}) {
      final img.Image source = img.Image(width: width, height: height);
      img.fill(source, color: img.ColorRgb8(30, 120, 40));
      source.exif.gpsIfd['GPSLatitude'] = img.IfdValueRational(1, 3);
      source.exif.imageIfd['Make'] = img.IfdValueAscii('PhoneMaker');
      return img.encodeJpg(source);
    }

    test('removes EXIF metadata such as GPS location', () {
      final Uint8List original = jpegWithGps(width: 64, height: 48);
      expect(img.decodeJpgExif(original)?.gpsIfd.isEmpty, isFalse);

      final Uint8List cleaned = ImageService.sanitizeImage(original)!;
      final img.ExifData? exif = img.decodeJpgExif(cleaned);
      expect(
        exif == null || (exif.gpsIfd.isEmpty && exif.imageIfd.isEmpty),
        isTrue,
      );
    });

    test('limits the longest side to ${ImageService.maxDimension} px', () {
      final Uint8List big = jpegWithGps(width: 3000, height: 2000);
      final img.Image result = img.decodeJpg(ImageService.sanitizeImage(big)!)!;
      expect(result.width, ImageService.maxDimension);
      expect(result.height, closeTo(853, 1));
    });

    test('returns null for data that is not an image', () {
      expect(
        ImageService.sanitizeImage(Uint8List.fromList(<int>[1, 2, 3])),
        isNull,
      );
    });
  });
}
