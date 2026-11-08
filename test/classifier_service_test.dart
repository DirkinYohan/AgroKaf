import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:agrokaf/core/constants/analysis_config.dart';
import 'package:agrokaf/features/analysis/data/classifier_service.dart';
import 'package:agrokaf/features/analysis/data/photo_quality_analyzer.dart';
import 'package:agrokaf/features/analysis/domain/classification_result.dart';

/// End-to-end: the same code path the app runs on the phone
/// (asset loading, background isolates, LiteRT inference).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final bool hasModel = File(AnalysisConfig.modelAsset).existsSync();

  late Directory temp;
  late File leaf;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('agrokaf_classify_');
    final img.Image image = img.Image(width: 640, height: 480);
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        image.setPixelRgb(
          x,
          y,
          40 + (x * 7 + y * 3) % 120,
          120 + (x ^ y) % 90,
          40,
        );
      }
    }
    leaf = File('${temp.path}/leaf.jpg')
      ..writeAsBytesSync(img.encodeJpg(image));
  });

  tearDown(() {
    try {
      temp.deleteSync(recursive: true);
    } on FileSystemException {
      // Windows may keep the file locked briefly.
    }
  });

  test('classify() runs through the background isolates', () async {
    final ClassifierService service = ClassifierService();
    await service.load();
    if (service.status != ModelStatus.ready) {
      markTestSkipped(
        'model not loadable on this host: ${service.unavailableReason}',
      );
      return;
    }
    addTearDown(service.dispose);

    final ClassificationResult result = await service.classify(leaf.path);
    expect(
      result.healthyProbability + result.phomaProbability,
      closeTo(1, 1e-3),
    );
    expect(result.inferenceMs, greaterThanOrEqualTo(0));
  }, skip: hasModel ? false : 'model files not copied to assets/model');

  test('photo quality check runs in a background isolate', () async {
    final Uint8List bytes = leaf.readAsBytesSync();
    final PhotoQualityReport report =
        await PhotoQualityAnalyzer.analyzeInBackground(bytes);
    expect(report.brightness, greaterThan(0));
  });
}
