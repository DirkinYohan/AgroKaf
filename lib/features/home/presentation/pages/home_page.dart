import 'package:flutter/material.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.marginMobile,
            vertical: AppSpacing.xl,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.eco,
                  size: 64,
                  color: AppColors.primary,
                  weight: 700,
                  fill: 1,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'AgroKaf',
                  style:
                      textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ) ??
                      TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Home Page - Placeholder',
                  textAlign: TextAlign.center,
                  style:
                      textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ) ??
                      TextStyle(
                        fontSize: 16,
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
