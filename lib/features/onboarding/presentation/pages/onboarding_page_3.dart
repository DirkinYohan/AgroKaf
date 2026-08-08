import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:agrokaf/core/constants/app_assets.dart';
import 'package:agrokaf/core/constants/app_routes.dart';
import 'package:agrokaf/core/router/app_router.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/widgets/onboarding_illustration_card.dart';
import 'package:agrokaf/core/widgets/pagination_dots_indicator.dart';
import 'package:agrokaf/core/widgets/primary_pill_button.dart';

class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({super.key});

  static const String _title = 'Obt\u00e9n un diagn\u00f3stico al instante.';
  static const String _description =
      'AgroKaf analiza la imagen directamente en tu dispositivo, sin necesidad de conexi\u00f3n a Internet.';
  static const String _backLabel = 'Atr\u00e1s';
  static const String _startLabel = 'Comenzar';
  static const int _currentPage = 2;
  static const int _totalPages = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingBackground,
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
                              top: 80,
                              bottom: AppSpacing.xxl,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                _buildIllustration(),
                                const SizedBox(
                                  height:
                                      AppSpacing.xl +
                                      AppSpacing.xl +
                                      AppSpacing.base,
                                ),
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
          _buildTopAppBar(context),
          _buildFixedFooter(context),
        ],
      ),
    );
  }

  double get _contentMaxWidth => 480;

  double get _footerReserveHeight => 132;

  Widget _buildTopAppBar(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.marginMobile,
            vertical: AppSpacing.sm,
          ),
          child: Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.basic,
              child: AnimatedOpacity(
                duration: AppAnimations.fast,
                opacity: 1.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.eco,
                      color: AppColors.primary,
                      weight: 700,
                      fill: 1,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'AgroKaf',
                      style:
                          textTheme.titleLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ) ??
                          TextStyle(
                            fontSize: 22,
                            height: 28 / 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return OnboardingIllustrationCard(
      imageAsset: AppAssets.onboarding3,
      aspectRatio: 4 / 5,
      maxSize: 320,
      radius: BorderRadius.circular(AppSpacing.radius2xl),
      animationDuration: AppAnimations.float,
      floatOffset: 12,
      backgroundColor: AppColors.surfaceContainerLowest,
      padding: const EdgeInsets.all(AppSpacing.md),
      border: Border.all(
        color: AppColors.surfaceVariant.withValues(alpha: 0.50),
      ),
      boxShadows: <BoxShadow>[
        BoxShadow(
          color: const Color(0xFF1B5E20).withValues(alpha: 0.06),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
      ],
      backgroundGradient: LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: <Color>[
          AppColors.surfaceContainerLow,
          AppColors.surfaceContainerLowest,
        ],
      ).scaleColors(0.50),
      imageBoxFit: BoxFit.contain,
      enableGradientOverlay: false,
    );
  }

  Widget _buildTypography(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDesktop =
        MediaQuery.of(context).size.width >= AppSpacing.tabletBreakpoint;
    return Column(
      children: <Widget>[
        Text(
          _title,
          textAlign: TextAlign.center,
          style:
              (isDesktop ? textTheme.headlineLarge : textTheme.headlineSmall)
                  ?.copyWith(color: AppColors.onSurface) ??
              TextStyle(
                fontSize: isDesktop ? 32 : 28,
                height: isDesktop ? 40 / 32 : 36 / 28,
                letterSpacing: isDesktop ? -0.32 : 0,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
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
    final double footerOpacity = 0.90;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: AppColors.onboardingBackground.withValues(
              alpha: footerOpacity,
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.marginMobile,
                  vertical: AppSpacing.lg,
                ).copyWith(bottom: 32),
                child: Center(
                  child: SizedBox(
                    width: _contentMaxWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        _buildBackButton(context),
                        _buildPagination(),
                        _buildStartButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return PrimaryPillButton(
      label: _backLabel,
      variant: PillButtonVariant.text,
      foregroundColor: AppColors.primary,
      hoverBackgroundColor: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      showShadow: false,
      onTap: () => _handleBack(context),
    );
  }

  Widget _buildPagination() {
    return PaginationDotsIndicator(
      currentIndex: _currentPage,
      totalCount: _totalPages,
      activeColor: AppColors.primaryContainer,
      activeSize: 8,
      activeWidth: 24,
      inactiveSize: 8,
      inactiveColor: AppColors.surfaceVariant.withValues(alpha: 0.60),
      gap: 8,
      borderRadius: BorderRadius.circular(999),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return PrimaryPillButton(
      label: _startLabel,
      variant: PillButtonVariant.filled,
      backgroundColor: AppColors.primaryContainer,
      foregroundColor: AppColors.onPrimaryContainer,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      showShadow: true,
      onTap: () => _handleStart(context),
    );
  }

  void _handleBack(BuildContext context) {
    AppRouter.pop(context);
  }

  void _handleStart(BuildContext context) {
    // TODO: persistir flag 'onboarding_completed' cuando se agregue la capa de datos.
    AppRouter.pushReplacement(context, AppRoutes.profile);
  }
}

extension _GradientScaling on Gradient {
  Gradient scaleColors(double opacity) {
    if (this is LinearGradient) {
      final LinearGradient lg = this as LinearGradient;
      return LinearGradient(
        begin: lg.begin,
        end: lg.end,
        colors: lg.colors
            .map((Color c) => c.withValues(alpha: opacity))
            .toList(),
        stops: lg.stops,
        tileMode: lg.tileMode,
      );
    }
    return this;
  }
}
