import 'package:flutter/material.dart';

import 'package:agrokaf/core/theme/app_colors.dart';

/// Possible outcomes of a leaf analysis, with their visual identity.
enum DiagnosisStatus {
  healthy(
    label: 'Sana',
    icon: Icons.check_circle_rounded,
    color: AppColors.healthy,
    containerColor: AppColors.healthyContainer,
  ),
  phoma(
    label: 'Posible muerte descendente',
    icon: Icons.warning_rounded,
    color: AppColors.phoma,
    containerColor: AppColors.phomaContainer,
  ),
  inconclusive(
    label: 'No concluyente',
    icon: Icons.help_rounded,
    color: AppColors.inconclusive,
    containerColor: AppColors.inconclusiveContainer,
  );

  const DiagnosisStatus({
    required this.label,
    required this.icon,
    required this.color,
    required this.containerColor,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color containerColor;
}
