import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agrokaf/core/app_state/app_state.dart';
import 'package:agrokaf/core/app_state/app_state_notifier.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/widgets/animated_loading_dots.dart';
import 'package:agrokaf/core/widgets/state_views.dart';
import 'package:agrokaf/features/splash/presentation/widgets/splash_logo_container.dart';

/// First screen: shows the logo while the app starts (encrypted database,
/// settings; the AI model in Phase 3). The router leaves this screen on its
/// own once the app state is ready.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  static const String tagline =
      'Tu aliado inteligente para detectar enfermedades del café';
  static const String startupErrorTitle = 'No pudimos iniciar AgroKaf';
  static const String startupErrorMessage =
      'Cierra la aplicación y vuelve a abrirla. Si el problema continúa, '
      'reinicia tu celular.';

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: AppDurations.entrance,
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _entrance,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.04),
    end: Offset.zero,
  ).animate(_fade);

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_start);
  }

  void _start() => ref.read(appStateProvider.notifier).bootstrap();

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool failed =
        ref.watch(appStateProvider.select((AppState s) => s.status)) ==
        StartupStatus.failed;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.9, -0.9),
            radius: 1.4,
            colors: <Color>[AppColors.primaryContainer, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SplashLogoContainer(),
                      const SizedBox(height: AppSpacing.lg),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppSizes.illustrationMax,
                        ),
                        child: Text(
                          SplashPage.tagline,
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      if (failed)
                        ErrorView(
                          title: SplashPage.startupErrorTitle,
                          message: SplashPage.startupErrorMessage,
                          onRetry: _start,
                        )
                      else
                        const AnimatedLoadingDots(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
