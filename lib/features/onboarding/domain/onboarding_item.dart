/// Content of one onboarding page.
class OnboardingItem {
  const OnboardingItem({
    required this.imageAsset,
    required this.title,
    required this.description,
    required this.imageSemanticLabel,
  });

  final String imageAsset;
  final String title;
  final String description;
  final String imageSemanticLabel;
}
