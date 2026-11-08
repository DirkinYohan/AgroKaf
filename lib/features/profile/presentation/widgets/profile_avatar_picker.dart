import 'package:flutter/material.dart';

import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/widgets/user_avatar.dart';

/// Large tappable avatar with "change" / "remove" actions.
class ProfileAvatarPicker extends StatelessWidget {
  const ProfileAvatarPicker({
    super.key,
    required this.onPickImage,
    this.photoPath,
    this.name,
    this.onRemoveImage,
    this.errorText,
  });

  static const String _addPhoto = 'Agregar foto';
  static const String _changePhoto = 'Cambiar foto';
  static const String _removePhoto = 'Quitar';

  final VoidCallback onPickImage;
  final String? photoPath;
  final String? name;
  final VoidCallback? onRemoveImage;
  final String? errorText;

  bool get _hasPhoto => photoPath != null && photoPath!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(
          button: true,
          label: _hasPhoto ? _changePhoto : _addPhoto,
          child: GestureDetector(
            onTap: onPickImage,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                UserAvatar(
                  imagePath: photoPath,
                  name: name,
                  size: AppSizes.avatarLg,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      color: AppColors.onPrimary,
                      size: AppSizes.iconSm,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.sm,
          children: <Widget>[
            TextButton.icon(
              onPressed: onPickImage,
              icon: const Icon(Icons.image_rounded, size: AppSizes.iconSm),
              label: Text(_hasPhoto ? _changePhoto : _addPhoto),
            ),
            if (_hasPhoto && onRemoveImage != null)
              TextButton.icon(
                onPressed: onRemoveImage,
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: AppSizes.iconSm,
                ),
                label: const Text(_removePhoto),
              ),
          ],
        ),
        if (errorText != null)
          Text(
            errorText!,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
      ],
    );
  }
}
