import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_litert/flutter_litert.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:agrokaf/core/constants/analysis_config.dart';
import 'package:agrokaf/core/models/model_info.dart';
import 'package:agrokaf/features/analysis/data/image_preprocessor.dart';
import 'package:agrokaf/features/analysis/domain/classification_result.dart';

/// Checks the bundled model files against the preprocessing contract.
void main() {
  final File infoFile = File(ModelInfo.assetPath);
  final File labelsFile = File(AnalysisConfig.labelsAsset);
  final File modelFile = File(AnalysisConfig.modelAsset);
  final bool hasModel =
      infoFile.existsSync() &&
      labelsFile.existsSync() &&
      modelFile.existsSync();

  test('model_info.json matches the contract the app implements', () {
    final Map<String, dynamic> json =
        jsonDecode(infoFile.readAsStringSync()) as Map<String, dynamic>;
    final Map<String, dynamic> input = json['input'] as Map<String, dynamic>;
    expect(input['shape'], <int>[1, 224, 224, 3]);
    expect(input['dtype'], 'float32');
    expect(input['value_range'], <int>[0, 255]);
    expect(input['color_order'], 'RGB');
    expect(input['resize_method'], 'bilinear');
    expect(input['layout'], 'NHWC');
    expect((json['output'] as Map<String, dynamic>)['type'], 'softmax');

    final ModelInfo info = ModelInfo.fromJson(json);
    final List<String> labels = labelsFile
        .readAsLinesSync()
        .map((String l) => l.trim())
        .where((String l) => l.isNotEmpty)
        .toList();
    expect(labels, info.classNames);
    expect(ClassificationResult.validateLabels(labels), isNull);
    expect(labels, <String>['healthy', 'other', 'phoma']);
  }, skip: hasModel ? false : 'model files not copied to assets/model');

  test('the .tflite runs on the host with the Dart preprocessing', () {
    Interpreter interpreter;
    try {
      interpreter = Interpreter.fromBuffer(modelFile.readAsBytesSync());
    } catch (e) {
      markTestSkipped('LiteRT native library not available on this host: $e');
      return;
    }
    interpreter.allocateTensors();
    expect(interpreter.getInputTensor(0).shape, <int>[1, 224, 224, 3]);
    expect(interpreter.getInputTensor(0).type, TensorType.float32);
    final int numClasses = labelsFile
        .readAsLinesSync()
        .where((String l) => l.trim().isNotEmpty)
        .length;
    expect(interpreter.getOutputTensor(0).shape, <int>[1, numClasses]);

    final img.Image leafLike = img.Image(width: 300, height: 300);
    img.fill(leafLike, color: img.ColorRgb8(60, 140, 50));
    final Float32List input = ImagePreprocessor.preprocess(
      img.encodeJpg(leafLike),
      width: 224,
      height: 224,
    );
    final Float32List output = Float32List(numClasses);
    interpreter.run(input, output);
    interpreter.close();

    expect(
      output.fold<double>(0, (double a, double b) => a + b),
      closeTo(1.0, 1e-3),
      reason: 'softmax output',
    );
    expect(output.every((double p) => p >= 0 && p <= 1), isTrue);
  }, skip: hasModel ? false : 'model files not copied to assets/model');
}
