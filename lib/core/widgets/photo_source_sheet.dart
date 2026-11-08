import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:agrokaf/core/services/photo_picker_service.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';

enum PhotoAction { camera, gallery, remove }

/// Bottom sheet to choose camera / gallery. It explains, before the OS asks
/// for any permission, why the camera or photos are needed.
Future<PhotoAction?> showPhotoSourceSheet(
  BuildContext context, {
  required String title,
  String message =
      'La foto se guarda solo en tu celular, sin datos de ubicación.',
  bool canRemove = false,
}) {
  return showModalBottomSheet<PhotoAction>(
    context: context,
    builder: (BuildContext sheetContext) {
      final TextTheme textTheme = Theme.of(sheetContext).textTheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(title, style: textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(message, style: textTheme.bodySmall),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Tomar foto con la cámara'),
                onTap: () => Navigator.pop(sheetContext, PhotoAction.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Elegir de la galería'),
                onTap: () => Navigator.pop(sheetContext, PhotoAction.gallery),
              ),
              if (canRemove)
                ListTile(
                  iconColor: AppColors.error,
                  textColor: AppColors.error,
                  leading: const Icon(Icons.delete_outline_rounded),
                  title: const Text('Quitar foto'),
                  onTap: () => Navigator.pop(sheetContext, PhotoAction.remove),
                ),
            ],
          ),
        ),
      );
    },
  );
}

/// Picks a photo and handles a denied permission with a friendly dialog.
/// Returns the picked path, or null if cancelled/denied.
Future<String?> pickPhotoWithFeedback(
  BuildContext context,
  PhotoPickerService picker,
  ImageSource source,
) async {
  try {
    return await picker.pick(source);
  } on PhotoPermissionDeniedException catch (e) {
    if (context.mounted) {
      await showPhotoPermissionDeniedDialog(context, e.source);
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pudimos abrir la cámara o la galería.'),
        ),
      );
    }
  }
  return null;
}

Future<void> showPhotoPermissionDeniedDialog(
  BuildContext context,
  ImageSource source,
) {
  final bool camera = source == ImageSource.camera;
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      icon: Icon(
        camera ? Icons.no_photography_outlined : Icons.hide_image_outlined,
        color: AppColors.secondary,
      ),
      title: Text(
        camera
            ? 'Permiso de cámara desactivado'
            : 'Permiso de fotos desactivado',
      ),
      content: Text(
        camera
            ? 'Para tomar la foto, AgroKaf necesita usar la cámara. Puedes '
                  'activar el permiso en los ajustes de tu celular.'
            : 'Para elegir una foto, AgroKaf necesita ver tus fotos. Puedes '
                  'activar el permiso en los ajustes de tu celular.',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Ahora no'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            AppSettings.openAppSettings();
          },
          child: const Text('Abrir ajustes'),
        ),
      ],
    ),
  );
}
