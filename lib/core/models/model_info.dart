import 'dart:convert';

import 'package:flutter/services.dart';

/// Contents of `assets/model/model_info.json`, written by the training
/// notebook. Only the fields the app needs are parsed.
class ModelInfo {
  const ModelInfo({
    required this.modelName,
    required this.classNames,
    required this.inputHeight,
    required this.inputWidth,
    this.createdAt,
    this.tensorflowVersion,
    this.testAccuracy,
    this.testMacroF1,
    this.testMacroPrecision,
    this.testMacroRecall,
    this.testImages,
  });

  static const String assetPath = 'assets/model/model_info.json';

  final String modelName;
  final List<String> classNames;
  final int inputHeight;
  final int inputWidth;
  final DateTime? createdAt;
  final String? tensorflowVersion;
  final double? testAccuracy;
  final double? testMacroF1;
  final double? testMacroPrecision;
  final double? testMacroRecall;
  final int? testImages;

  /// Human-readable version, e.g. "agrokaf_phoma_detector · 2026-11-08".
  String get version {
    final DateTime? date = createdAt;
    if (date == null) return modelName;
    final String day = date.toIso8601String().substring(0, 10);
    return '$modelName · $day';
  }

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> input =
        (json['input'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final List<dynamic> shape =
        (input['shape'] as List<dynamic>?) ?? <dynamic>[1, 224, 224, 3];
    final Map<String, dynamic> metrics =
        (json['test_metrics'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    double? asDouble(Object? v) => v is num ? v.toDouble() : null;

    return ModelInfo(
      modelName: (json['model_name'] as String?) ?? 'agrokaf',
      classNames: ((json['class_names'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic e) => e.toString())
          .toList(growable: false),
      inputHeight: (shape[1] as num).toInt(),
      inputWidth: (shape[2] as num).toInt(),
      createdAt: DateTime.tryParse((json['created_at'] as String?) ?? ''),
      tensorflowVersion: json['tensorflow_version'] as String?,
      testAccuracy: asDouble(metrics['accuracy']),
      testMacroF1: asDouble(metrics['macro_f1']),
      testMacroPrecision: asDouble(metrics['macro_precision']),
      testMacroRecall: asDouble(metrics['macro_recall']),
      testImages: (metrics['num_images'] as num?)?.toInt(),
    );
  }

  /// Loads the bundled model card, or returns null if it is missing/invalid.
  static Future<ModelInfo?> load({AssetBundle? bundle}) async {
    try {
      final String raw = await (bundle ?? rootBundle).loadString(assetPath);
      return ModelInfo.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
