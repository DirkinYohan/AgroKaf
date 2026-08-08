import 'package:flutter/material.dart';
import 'package:agrokaf/core/constants/app_routes.dart';
import 'package:agrokaf/core/router/app_router.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/widgets/animated_loading_dots.dart';
import 'package:agrokaf/features/splash/presentation/widgets/splash_background_decorations.dart';
import 'package:agrokaf/features/splash/presentation/widgets/splash_logo_container.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  static const Duration _splashDuration = Duration(seconds: 3);

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.fadeInUp,
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.035),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
    _scheduleNavigation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scheduleNavigation() {
    Future<void>.delayed(_splashDuration, () {
      if (!mounted) return;
      AppRouter.pushReplacement(context, AppRoutes.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: <Widget>[
          const SplashBackgroundDecorations(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile,
                vertical: AppSpacing.xl,
              ),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: <Widget>[
                            const Spacer(flex: 1),
                            Expanded(
                              flex: 4,
                              child: _buildAnimatedContent(context),
                            ),
                            const Spacer(flex: 2),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedContent(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _buildCenterContent(context),
      ),
    );
  }

  Widget _buildCenterContent(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SplashLogoContainer(),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: SizedBox(
            width: 360,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                'Tu aliado inteligente para detectar enfermedades del caf\u00e9',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const AnimatedLoadingDots(),
      ],
    );
  }
}
