import 'package:flutter/material.dart';

import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/widgets/app_button.dart';

/// The single primary action of the app: analyze a leaf from camera or
/// gallery. White text on dark green (contrast ~ 7.9:1).
class AnalyzeCard extends StatelessWidget {
  const AnalyzeCard({
    super.key,
    required this.onCamera,
    required this.onGallery,
  });

  static const String _title = 'Analiza una planta';
  static const String _message =
      'Toma una foto de una hoja de café o elígela de tu galería.';
  static const String _camera = 'Cámara';
  static const String _gallery = 'Galería';

  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.xlAll,
        boxShadow: AppShadows.elevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.onPrimary.withValues(alpha: 0.15),
                  borderRadius: AppRadius.mdAll,
                ),
                child: const Icon(
                  Icons.document_scanner_outlined,
                  color: AppColors.onPrimary,
                  size: AppSizes.iconLg,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  _title,
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _message,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.onPrimary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: <Widget>[
              Expanded(
                child: AppButton(
                  label: _camera,
                  icon: Icons.photo_camera_rounded,
                  variant: AppButtonVariant.inverse,
                  onPressed: onCamera,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onGallery,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onPrimary,
                    side: const BorderSide(
                      color: AppColors.onPrimary,
                      width: 1.5,
                    ),
                  ),
                  icon: const Icon(
                    Icons.photo_library_rounded,
                    size: AppSizes.iconSm,
                  ),
                  label: const Text(_gallery),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
