import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agrokaf/core/app_state/app_state_notifier.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/widgets/app_button.dart';
import 'package:agrokaf/core/widgets/app_logo.dart';
import 'package:agrokaf/core/widgets/page_indicator.dart';
import 'package:agrokaf/features/onboarding/data/onboarding_content.dart';
import 'package:agrokaf/features/onboarding/presentation/widgets/onboarding_page_view.dart';

/// Three-page onboarding with a shared header, indicator and footer.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const String skipLabel = 'Omitir';
  static const String backLabel = 'Atrás';
  static const String nextLabel = 'Siguiente';
  static const String startLabel = 'Comenzar';

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool get _isFirstPage => _currentPage == 0;
  bool get _isLastPage => _currentPage == onboardingItems.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: AppDurations.medium,
      curve: Curves.easeOutCubic,
    );
  }

  void _handleNext() => _isLastPage ? _finish() : _goToPage(_currentPage + 1);

  void _handleBack() => _goToPage(_currentPage - 1);

  /// Persists the flag; the router then moves on to the privacy consent.
  void _finish() => ref.read(appStateProvider.notifier).completeOnboarding();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _isFirstPage,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              _Header(showSkip: !_isLastPage, onSkip: _finish),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingItems.length,
                  onPageChanged: (int page) =>
                      setState(() => _currentPage = page),
                  itemBuilder: (_, int index) =>
                      OnboardingPageView(item: onboardingItems[index]),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              PageIndicator(
                count: onboardingItems.length,
                current: _currentPage,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Row(
                  children: <Widget>[
                    Visibility(
                      visible: !_isFirstPage,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: AppButton(
                        label: OnboardingScreen.backLabel,
                        variant: AppButtonVariant.text,
                        onPressed: _isFirstPage ? null : _handleBack,
                      ),
                    ),
                    const Spacer(),
                    AppButton(
                      label: _isLastPage
                          ? OnboardingScreen.startLabel
                          : OnboardingScreen.nextLabel,
                      icon: Icons.arrow_forward_rounded,
                      trailingIcon: true,
                      onPressed: _handleNext,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Logo centered on every page, "Omitir" on the right (hidden on the last).
class _Header extends StatelessWidget {
  const _Header({required this.showSkip, required this.onSkip});

  final bool showSkip;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: SizedBox(
        height: AppSizes.logoHeader,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            const AppLogo(height: AppSizes.logoHeader, framed: true),
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedOpacity(
                opacity: showSkip ? 1 : 0,
                duration: AppDurations.fast,
                child: IgnorePointer(
                  ignoring: !showSkip,
                  child: AppButton(
                    label: OnboardingScreen.skipLabel,
                    variant: AppButtonVariant.text,
                    onPressed: onSkip,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
