import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:agrokaf/core/constants/app_routes.dart';
import 'package:agrokaf/core/providers/service_providers.dart';
import 'package:agrokaf/core/widgets/photo_source_sheet.dart';

/// Picks a leaf photo from [source] and opens the preview screen.
/// With [replace] the current screen is replaced (used by "Analizar otra").
Future<void> startAnalysis(
  BuildContext context,
  WidgetRef ref,
  ImageSource source, {
  bool replace = false,
}) async {
  final String? path = await pickPhotoWithFeedback(
    context,
    ref.read(photoPickerServiceProvider),
    source,
  );
  if (path == null || !context.mounted) return;
  if (replace) {
    context.pushReplacement(AppRoutes.analysisPreview, extra: path);
  } else {
    context.push(AppRoutes.analysisPreview, extra: path);
  }
}

/// Asks camera or gallery first, then [startAnalysis].
Future<void> chooseSourceAndStartAnalysis(
  BuildContext context,
  WidgetRef ref, {
  bool replace = false,
}) async {
  final PhotoAction? action = await showPhotoSourceSheet(
    context,
    title: 'Analizar otra hoja',
  );
  if (action == null || !context.mounted) return;
  await startAnalysis(
    context,
    ref,
    action == PhotoAction.camera ? ImageSource.camera : ImageSource.gallery,
    replace: replace,
  );
}
