import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

import 'package:agrokaf/core/services/image_service.dart';
import 'package:agrokaf/features/analysis/data/classifier_service.dart';
import 'package:agrokaf/features/analysis/data/photo_quality_analyzer.dart';
import 'package:agrokaf/features/analysis/domain/classification_result.dart';

/// Runs every step of "Analizar" on a real device, one test per step, so a
/// failure points at the exact step and prints the real error.
///
///   `flutter test integration_test/analysis_pipeline_test.dart -d DEVICE_ID`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late String pickedPath;
  late String workingPath;
  final ImageService images = ImageService();
  final ClassifierService classifier = ClassifierService();

  setUpAll(() async {
    // Simulates a photo returned by the picker (stored in the cache dir).
    final img.Image photo = img.Image(width: 1600, height: 1200);
    for (int y = 0; y < photo.height; y++) {
      for (int x = 0; x < photo.width; x++) {
        photo.setPixelRgb(
          x,
          y,
          40 + (x * 7 + y * 3) % 120,
          120 + (x ^ y) % 90,
          40,
        );
      }
    }
    final Directory cache = await getTemporaryDirectory();
    pickedPath = '${cache.path}/picked_test.jpg';
    File(pickedPath).writeAsBytesSync(img.encodeJpg(photo));
  });

  tearDownAll(() async {
    await classifier.dispose();
    await images.deleteImage(workingPath);
  });

  testWidgets('1. private, metadata-free copy', (WidgetTester tester) async {
    workingPath =
        await tester.runAsync(
              () => images.savePrivateImage(pickedPath, ImageFolder.analyses),
            )
            as String;
    expect(File(workingPath).existsSync(), isTrue);
  });

  testWidgets('2. photo quality check (background isolate)', (
    WidgetTester tester,
  ) async {
    final Uint8List bytes = File(workingPath).readAsBytesSync();
    final PhotoQualityReport? report = await tester.runAsync(
      () => PhotoQualityAnalyzer.analyzeInBackground(bytes),
    );
    expect(report, isNotNull);
  });

  testWidgets('3. model loads', (WidgetTester tester) async {
    await tester.runAsync(classifier.load);
    expect(
      classifier.status,
      ModelStatus.ready,
      reason: 'unavailable: ${classifier.unavailableReason}',
    );
  });

  testWidgets('4. classify (preprocess isolate + LiteRT isolate)', (
    WidgetTester tester,
  ) async {
    Object? error;
    StackTrace? stack;
    ClassificationResult? result;
    await tester.runAsync(() async {
      try {
        result = await classifier.classify(workingPath);
      } catch (e, s) {
        error = e;
        stack = s;
      }
    });
    expect(error, isNull, reason: 'classify failed: $error\n$stack');
    expect(
      result!.healthyProbability + result!.phomaProbability,
      closeTo(1, 1e-3),
    );
    // ignore: avoid_print
    print(
      'RESULT ${result!.probabilities} in ${result!.inferenceMs} ms '
      '(preprocess ${result!.preprocessMs} ms)',
    );
  });

  testWidgets('5. clear temporary files', (WidgetTester tester) async {
    Object? error;
    await tester.runAsync(() async {
      try {
        await images.clearTemporaryFiles();
      } catch (e) {
        error = e;
      }
    });
    expect(error, isNull, reason: 'clearTemporaryFiles failed: $error');
  });
}
