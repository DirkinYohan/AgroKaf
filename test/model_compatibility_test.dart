import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agrokaf/core/constants/analysis_config.dart';
import 'package:agrokaf/core/models/model_info.dart';
import 'package:agrokaf/features/analysis/data/classifier_service.dart';

/// Serves a fake labels.txt / model_info.json.
class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this.labels);

  final List<String> labels;

  @override
  Future<ByteData> load(String key) async {
    final String text = switch (key) {
      AnalysisConfig.labelsAsset => labels.join('\n'),
      ModelInfo.assetPath => jsonEncode(<String, Object>{
        'model_name': 'fake',
        'class_names': labels,
        'input': <String, Object>{
          'shape': <int>[1, 224, 224, 3],
        },
      }),
      _ => throw StateError('missing asset $key'),
    };
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(text)));
  }
}

/// No model files at all.
class _EmptyBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      throw StateError('missing asset $key');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'unknown class name in labels.txt -> "incompatible", no crash',
    () async {
      final ClassifierService service = ClassifierService(
        bundle: _FakeBundle(<String>['healthy', 'phoma', 'rust']),
      );
      await service.load();
      expect(service.status, ModelStatus.incompatible);
      expect(service.unavailableReason, contains('rust'));
      expect(
        () => service.classify('/nothing.jpg'),
        throwsA(isA<ModelUnavailableException>()),
      );
    },
  );

  test('missing model files -> "unavailable"', () async {
    final ClassifierService service = ClassifierService(bundle: _EmptyBundle());
    await service.load();
    expect(service.status, ModelStatus.unavailable);
  });
}
