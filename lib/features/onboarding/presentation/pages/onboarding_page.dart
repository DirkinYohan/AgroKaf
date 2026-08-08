import 'package:flutter/material.dart';
import 'package:agrokaf/core/constants/app_assets.dart';
import 'package:agrokaf/core/constants/app_routes.dart';
import 'package:agrokaf/core/router/app_router.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/widgets/onboarding_illustration_card.dart';
import 'package:agrokaf/core/widgets/pagination_dots_indicator.dart';
import 'package:agrokaf/core/widgets/primary_pill_button.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  static const String _title = 'Bienvenido a AgroKaf.';
  static const String _description =
      'La inteligencia artificial te ayuda a detectar de forma temprana '
      'la enfermedad muerte descendente en plantas de caf\u00e9.';
  static const String _skipLabel = 'Omitir';
  static const String _nextLabel = 'Siguiente';

  static const double _shortScreenBreakpoint = 660;
  static const double _descriptionMaxWidth = 320;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.marginMobile,
                    vertical: AppSpacing.xl,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: _contentMaxWidth,
                      height: constraints.maxHeight - (AppSpacing.xl * 2),
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: _buildIllustrationAndText(
                              context,
                              constraints,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.lg,
                            ),
                            child: PaginationDotsIndicator(
                              currentIndex: 0,
                              totalCount: 3,
                            ),
                          ),
                          _buildFooter(context),
                          const SizedBox(height: AppSpacing.base),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  double get _contentMaxWidth => 560;

  Widget _buildIllustrationAndText(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isShort = constraints.maxHeight < _shortScreenBreakpoint;
    final double titleGap = isShort ? AppSpacing.sm : AppSpacing.md;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          flex: 5,
          child: Center(
            child: OnboardingIllustrationCard(
              imageAsset: AppAssets.onboarding1,
              maxSize: AppSpacing.illustrationMaxSize,
            ),
          ),
        ),
        SizedBox(height: isShort ? AppSpacing.lg : AppSpacing.xl),
        Flexible(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Text(
                    _title,
                    textAlign: TextAlign.center,
                    style: _titleStyle(textTheme, isShort),
                  ),
                ),
                SizedBox(height: titleGap),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: _descriptionMaxWidth),
                    child: Text(
                      _description,
                      textAlign: TextAlign.center,
                      style: _descriptionStyle(textTheme, isShort),
                      textWidthBasis: TextWidthBasis.longestLine,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  TextStyle _titleStyle(TextTheme textTheme, bool isShort) {
    if (isShort) {
      return textTheme.headlineMedium?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
            height: 32 / 24,
          ) ??
          TextStyle(
            fontSize: 24,
            height: 32 / 24,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          );
    }
    return textTheme.headlineSmall?.copyWith(color: AppColors.onSurface) ??
        TextStyle(
          fontSize: 28,
          height: 36 / 28,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        );
  }

  TextStyle _descriptionStyle(TextTheme textTheme, bool isShort) {
    if (isShort) {
      return textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 20 / 14,
          ) ??
          TextStyle(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurfaceVariant,
          );
    }
    return textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariant) ??
        TextStyle(
          fontSize: 16,
          height: 24 / 16,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurfaceVariant,
        );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          PrimaryPillButton(
            label: _skipLabel,
            variant: PillButtonVariant.text,
            onTap: () => _handleSkip(context),
          ),
          PrimaryPillButton(
            label: _nextLabel,
            icon: Icons.arrow_forward,
            variant: PillButtonVariant.filled,
            onTap: () => _handleNext(context),
          ),
        ],
      ),
    );
  }

  void _handleSkip(BuildContext context) {
    AppRouter.pushReplacement(context, AppRoutes.home);
  }

  void _handleNext(BuildContext context) {
    AppRouter.push(context, AppRoutes.onboarding2);
  }
}
