import 'package:agrokaf/core/constants/app_assets.dart';
import 'package:agrokaf/features/onboarding/domain/onboarding_item.dart';

/// The three onboarding pages, in order.
const List<OnboardingItem> onboardingItems = <OnboardingItem>[
  OnboardingItem(
    imageAsset: AppAssets.onboardingWelcome,
    title: 'Bienvenido a AgroKaf',
    description:
        'La inteligencia artificial te ayuda a detectar a tiempo la muerte '
        'descendente en tus plantas de café.',
    imageSemanticLabel: 'Caficultor revisando sus plantas con el celular',
  ),
  OnboardingItem(
    imageAsset: AppAssets.onboardingAnalyze,
    title: 'Analiza tus plantas fácilmente',
    description:
        'Toma una foto de la hoja o elígela de tu galería para analizarla.',
    imageSemanticLabel: 'Celular enfocando una hoja de café con la cámara',
  ),
  OnboardingItem(
    imageAsset: AppAssets.onboardingDiagnosis,
    title: 'Obtén un diagnóstico al instante',
    description:
        'AgroKaf analiza la foto en tu celular, sin necesidad de internet.',
    imageSemanticLabel: 'Celular mostrando un diagnóstico completado',
  ),
];
