import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:agrokaf/core/models/model_info.dart';

/// Installed app version, e.g. "1.0.0 (1)".
final FutureProvider<String> appVersionProvider = FutureProvider<String>((
  Ref ref,
) async {
  final PackageInfo info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

/// Bundled model card, or null when the model files are not in the app.
final FutureProvider<ModelInfo?> modelInfoProvider = FutureProvider<ModelInfo?>(
  (Ref ref) => ModelInfo.load(),
);
