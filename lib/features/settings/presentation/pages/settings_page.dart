import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agrokaf/core/app_state/app_state_notifier.dart';
import 'package:agrokaf/core/constants/app_routes.dart';
import 'package:agrokaf/core/services/settings_service.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/utils/date_formatter.dart';
import 'package:agrokaf/core/widgets/app_card.dart';
import 'package:agrokaf/features/analysis/presentation/providers/analysis_providers.dart';
import 'package:agrokaf/features/home/presentation/widgets/home_sections.dart';
import 'package:agrokaf/features/profile/presentation/providers/profile_providers.dart';

/// Ajustes: profile, privacy, about and "delete all my data".
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const String title = 'Ajustes';
  static const String deleteAllLabel = 'Eliminar todos mis datos';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PrivacyConsent? consent = ref.watch(
      appStateProvider.select((s) => s.consent),
    );
    return Scaffold(
      appBar: AppBar(title: const Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: <Widget>[
          const SectionTitle(title: 'Tu cuenta'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar perfil'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(AppRoutes.profileEdit),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionTitle(title: 'Privacidad e información'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Política de privacidad'),
                  subtitle: consent == null
                      ? null
                      : Text(
                          'Aceptada el ${DateFormatter.longDate(consent.acceptedAt)}',
                        ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(AppRoutes.privacyPolicy),
                ),
                const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('Acerca de AgroKaf'),
                  subtitle: const Text('Versión, modelo y créditos'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(AppRoutes.about),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionTitle(title: 'Tus datos'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: ListTile(
              iconColor: AppColors.error,
              textColor: AppColors.error,
              leading: const Icon(Icons.delete_forever_outlined),
              title: const Text(deleteAllLabel),
              subtitle: const Text(
                'Borra tu perfil, tus fotos y tu historial de este celular.',
              ),
              onTap: () => _confirmDeleteAll(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAll(BuildContext context, WidgetRef ref) async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            icon: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
            ),
            title: const Text('¿Eliminar todos tus datos?'),
            content: const Text(
              'Se borrarán de este celular tu perfil, tu foto, todas las fotos '
              'de hojas y tu historial de análisis. Esta acción no se puede '
              'deshacer y la app volverá a empezar desde cero.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.onError,
                ),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Eliminar todo'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
    final NavigatorState rootNavigator = Navigator.of(
      context,
      rootNavigator: true,
    );
    final AppStateNotifier appState = ref.read(appStateProvider.notifier);
    try {
      await appState.deleteAllData();
      rootNavigator.pop(); // close the progress dialog first...
      ref.invalidate(profileProvider);
      ref.invalidate(analysesProvider);
      appState.restartFirstRun(); // ...then the router opens onboarding.
    } catch (_) {
      rootNavigator.pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No pudimos borrar todos los datos. Inténtalo de nuevo.',
            ),
          ),
        );
      }
    }
  }
}
