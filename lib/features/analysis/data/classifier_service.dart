import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_litert/flutter_litert.dart';

import 'package:agrokaf/core/constants/analysis_config.dart';
import 'package:agrokaf/core/models/model_info.dart';
import 'package:agrokaf/features/analysis/data/image_preprocessor.dart';
import 'package:agrokaf/features/analysis/domain/classification_result.dart';

enum ModelStatus { notLoaded, loading, ready, unavailable }

/// The model files are missing or do not match model_info.json.
class ModelUnavailableException implements Exception {
  const ModelUnavailableException(this.reason);

  final String reason;

  @override
  String toString() => 'ModelUnavailableException: $reason';
}

/// Runs the AgroKaf LiteRT model fully offline.
///
/// The interpreter is created once (at startup) and reused. Preprocessing
/// runs in a short-lived isolate and inference in a long-lived
/// [IsolateInterpreter], so the UI never freezes.
class ClassifierService {
  ClassifierService({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  ModelStatus _status = ModelStatus.notLoaded;
  String? _unavailableReason;
  ModelInfo? _info;
  List<String> _labels = const <String>[];
  Interpreter? _interpreter;
  IsolateInterpreter? _isolateInterpreter;
  Future<void>? _loading;

  ModelStatus get status => _status;
  bool get isReady => _status == ModelStatus.ready;
  String? get unavailableReason => _unavailableReason;
  ModelInfo? get info => _info;
  List<String> get labels => _labels;

  /// Loads the model once. Never throws: on failure [status] becomes
  /// [ModelStatus.unavailable] and the app shows "Modelo no disponible".
  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    _status = ModelStatus.loading;
    try {
      final ModelInfo info =
          await ModelInfo.load(bundle: _bundle) ??
          (throw const ModelUnavailableException('model_info.json not found'));
      final List<String> labels =
          (await _bundle.loadString(AnalysisConfig.labelsAsset))
              .split('\n')
              .map((String l) => l.trim())
              .where((String l) => l.isNotEmpty)
              .toList(growable: false);
      if (info.classNames.isNotEmpty &&
          info.classNames.join(',') != labels.join(',')) {
        throw const ModelUnavailableException(
          'labels.txt does not match model_info.json',
        );
      }

      final InterpreterOptions options = InterpreterOptions()
        ..threads = AnalysisConfig.inferenceThreads;
      final Interpreter interpreter = await Interpreter.fromAsset(
        AnalysisConfig.modelAsset,
        options: options,
      );
      interpreter.allocateTensors();
      _checkTensors(interpreter, info, labels.length);

      _isolateInterpreter = await IsolateInterpreter.create(
        address: interpreter.address,
      );
      _interpreter = interpreter;
      _info = info;
      _labels = labels;
      _status = ModelStatus.ready;
    } catch (e) {
      _status = ModelStatus.unavailable;
      _unavailableReason = e is ModelUnavailableException
          ? e.reason
          : e.runtimeType.toString();
      _interpreter?.close();
      _interpreter = null;
    }
  }

  /// Verifies the .tflite really has the shapes the contract promises.
  static void _checkTensors(
    Interpreter interpreter,
    ModelInfo info,
    int numLabels,
  ) {
    final Tensor input = interpreter.getInputTensor(0);
    final Tensor output = interpreter.getOutputTensor(0);
    final List<int> expectedInput = <int>[
      1,
      info.inputHeight,
      info.inputWidth,
      ImagePreprocessor.channels,
    ];
    if (input.type != TensorType.float32 ||
        input.shape.join(',') != expectedInput.join(',')) {
      throw ModelUnavailableException(
        'unexpected input tensor ${input.shape} ${input.type}',
      );
    }
    if (output.shape.last != numLabels) {
      throw ModelUnavailableException(
        'unexpected output tensor ${output.shape}',
      );
    }
  }

  /// Classifies the image at [imagePath]. Requires [isReady].
  Future<ClassificationResult> classify(String imagePath) async {
    final IsolateInterpreter? runner = _isolateInterpreter;
    final ModelInfo? info = _info;
    if (!isReady || runner == null || info == null) {
      throw ModelUnavailableException(_unavailableReason ?? 'model not loaded');
    }

    final Uint8List bytes = await File(imagePath).readAsBytes();
    final int width = info.inputWidth;
    final int height = info.inputHeight;

    final Stopwatch preprocessWatch = Stopwatch()..start();
    final Float32List input = await _preprocessInBackground(
      bytes,
      width,
      height,
    );
    preprocessWatch.stop();

    final Float32List output = Float32List(_labels.length);
    final Stopwatch inferenceWatch = Stopwatch()..start();
    await runner.run(input, output);
    inferenceWatch.stop();

    return ClassificationResult.fromOutput(
      labels: _labels,
      output: output,
      preprocessMs: preprocessWatch.elapsedMilliseconds,
      inferenceMs: inferenceWatch.elapsedMilliseconds,
    );
  }

  /// Static on purpose: the isolate closure must capture only these
  /// arguments, never `this` (which holds the interpreter and ports).
  static Future<Float32List> _preprocessInBackground(
    Uint8List bytes,
    int width,
    int height,
  ) => Isolate.run(
    () => ImagePreprocessor.preprocess(bytes, width: width, height: height),
  );

  Future<void> dispose() async {
    await _isolateInterpreter?.close();
    _interpreter?.close();
    _isolateInterpreter = null;
    _interpreter = null;
    _status = ModelStatus.notLoaded;
    _loading = null;
  }
}
