import 'dart:io';
import 'package:flutter/material.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';

class ProfileAvatarPicker extends StatelessWidget {
  const ProfileAvatarPicker({
    super.key,
    this.photoPath,
    this.onPickImage,
    this.onRemoveImage,
  });

  final String? photoPath;
  final Future<void> Function()? onPickImage;
  final VoidCallback? onRemoveImage;

  static const double avatarSize = 120;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GestureDetector(
          onTap: onPickImage,
          child: Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppColors.surfaceContainerLow,
                  AppColors.surfaceContainer,
                ],
              ),
              boxShadow: AppShadows.cardSm,
              border: Border.all(
                color: AppColors.surfaceVariant.withValues(alpha: 0.60),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: photoPath == null
                  ? _buildPlaceholder()
                  : _buildPhotoImage(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildChangeButton(context),
            if (photoPath != null && onRemoveImage != null) ...<Widget>[
              const SizedBox(width: AppSpacing.md),
              _buildRemoveButton(context),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.person_rounded,
        size: 64,
        color: AppColors.onSurfaceVariant.withValues(alpha: 0.48),
      ),
    );
  }

  Widget _buildPhotoImage() {
    final File file = File(photoPath!);
    final bool fileExists = file.existsSync();
    if (!fileExists) return _buildPlaceholder();
    return Image.file(
      file,
      fit: BoxFit.cover,
      width: avatarSize,
      height: avatarSize,
      errorBuilder: (_, _, _) => _buildPlaceholder(),
    );
  }

  Widget _buildChangeButton(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return TextButton.icon(
      onPressed: onPickImage,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryContainer,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
      icon: const Icon(Icons.photo_camera_rounded, size: 18),
      label: Text(
        photoPath == null ? 'Seleccionar foto' : 'Cambiar foto',
        style:
            textTheme.labelMedium?.copyWith(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w500,
                ) ??
                TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryContainer,
                ),
      ),
    );
  }

  Widget _buildRemoveButton(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return TextButton.icon(
      onPressed: onRemoveImage,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.error,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
      icon: const Icon(Icons.delete_outline_rounded, size: 18),
      label: Text(
        'Eliminar',
        style:
            textTheme.labelMedium?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ) ??
                TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
      ),
    );
  }
}
