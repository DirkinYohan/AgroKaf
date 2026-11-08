import 'dart:io';

import 'package:flutter/material.dart';

import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';

/// Circular avatar: the profile photo, or the user's initial as fallback.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.imagePath,
    this.name,
    this.size = AppSizes.avatarSm,
  });

  final String? imagePath;
  final String? name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final String? path = imagePath;
    final bool hasImage =
        path != null && path.isNotEmpty && File(path).existsSync();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryContainer,
        border: Border.all(color: AppColors.surface, width: 2),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.file(
              File(path),
              fit: BoxFit.cover,
              cacheWidth: (size * 3).round(),
              errorBuilder: (_, _, _) => _fallback(context),
            )
          : _fallback(context),
    );
  }

  Widget _fallback(BuildContext context) {
    final String trimmed = (name ?? '').trim();
    if (trimmed.isEmpty) {
      return Icon(
        Icons.person_rounded,
        color: AppColors.primary,
        size: size * 0.55,
      );
    }
    return Center(
      child: Text(
        trimmed.characters.first.toUpperCase(),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.primary,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}
