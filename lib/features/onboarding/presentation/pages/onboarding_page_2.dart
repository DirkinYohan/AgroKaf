import 'package:flutter/material.dart';
import 'package:agrokaf/core/constants/app_assets.dart';
import 'package:agrokaf/core/constants/app_routes.dart';
import 'package:agrokaf/core/router/app_router.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/widgets/onboarding_illustration_card.dart';
import 'package:agrokaf/core/widgets/pagination_dots_indicator.dart';
import 'package:agrokaf/core/widgets/primary_pill_button.dart';
import 'package:agrokaf/features/onboarding/presentation/widgets/camera_frame_overlay.dart';

class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

  static const String _title = 'Analiza tus plantas f\u00e1cilmente.';
  static const String _description =
      'Toma una fotograf\u00eda o selecciona una imagen desde la galer\u00eda '
      'para analizar la planta.';
  static const String _backLabel = 'Atr\u00e1s';
  static const String _nextLabel = 'Siguiente';
  static const int _currentPage = 1;
  static const int _totalPages = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: <Widget>[
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    bottom: _footerReserveHeight + AppSpacing.lg,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.marginMobile,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: _contentMaxWidth,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: AppSpacing.xl,
                              bottom: AppSpacing.xxl,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                _buildIllustration(),
                                const SizedBox(height: AppSpacing.xl),
                                _buildTypography(context),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildFixedFooter(context),
        ],
      ),
    );
  }

  double get _contentMaxWidth => 480;

  double get _footerReserveHeight => 132;

  Duration get _floatDuration => const Duration(seconds: 4);

  Widget _buildIllustration() {
    return OnboardingIllustrationCard(
      imageAsset: AppAssets.onboarding2,
      animationDuration: _floatDuration,
      backgroundColor: AppColors.surfaceContainer,
      padding: const EdgeInsets.all(AppSpacing.xl),
      border: Border.all(color: AppColors.outlineVariant),
      imageBoxFit: BoxFit.contain,
      imageWidthFactor: 0.75,
      imageHeightFactor: 0.75,
      enableGradientOverlay: false,
      overlayWidget: const CameraFrameOverlay(),
    );
  }

  Widget _buildTypography(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        Text(
          _title,
          textAlign: TextAlign.center,
          style:
              textTheme.headlineSmall?.copyWith(color: AppColors.primary) ??
              TextStyle(
                fontSize: 28,
                height: 36 / 28,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: 300,
          child: Text(
            _description,
            textAlign: TextAlign.center,
            style:
                textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ) ??
                TextStyle(
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildFixedFooter(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: _contentMaxWidth,
          child: Container(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusXl),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.marginMobile,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const PaginationDotsIndicator(
                      currentIndex: _currentPage,
                      totalCount: _totalPages,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildFooterRow(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        PrimaryPillButton(
          label: _backLabel,
          variant: PillButtonVariant.text,
          foregroundColor: AppColors.secondary,
          hoverBackgroundColor: AppColors.primaryFixedDim.withValues(
            alpha: 0.10,
          ),
          onTap: () => _handleBack(context),
        ),
        PrimaryPillButton(
          label: _nextLabel,
          icon: Icons.arrow_forward,
          variant: PillButtonVariant.filled,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          onTap: () => _handleNext(context),
        ),
      ],
    );
  }

  void _handleBack(BuildContext context) {
    AppRouter.pop(context);
  }

  void _handleNext(BuildContext context) {
    AppRouter.push(context, AppRoutes.onboarding3);
  }
}
