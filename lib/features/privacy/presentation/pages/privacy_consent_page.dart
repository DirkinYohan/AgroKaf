import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agrokaf/core/app_state/app_state_notifier.dart';
import 'package:agrokaf/core/constants/app_info.dart';
import 'package:agrokaf/core/constants/app_routes.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/widgets/app_button.dart';
import 'package:agrokaf/core/widgets/app_card.dart';
import 'package:agrokaf/core/widgets/app_logo.dart';
import 'package:agrokaf/features/privacy/domain/privacy_policy.dart';
import 'package:agrokaf/features/privacy/presentation/widgets/policy_section_tile.dart';

/// Express authorization required by Ley 1581 de 2012, shown before any
/// personal data is collected.
class PrivacyConsentPage extends ConsumerStatefulWidget {
  const PrivacyConsentPage({super.key});

  static const String title = 'Tu privacidad es lo primero';
  static const String acceptCheckbox =
      'He leído la política de privacidad y autorizo a AgroKaf a guardar mis '
      'datos en este celular.';
  static const String acceptButton = 'Aceptar y continuar';

  @override
  ConsumerState<PrivacyConsentPage> createState() => _PrivacyConsentPageState();
}

class _PrivacyConsentPageState extends ConsumerState<PrivacyConsentPage> {
  static const String _intro =
      'Antes de empezar, te contamos de forma sencilla qué datos usa AgroKaf '
      'y cómo los protegemos.';
  static const String _readFull = 'Leer la política completa';
  static const String _revokeNote =
      'Puedes retirar tu autorización cuando quieras borrando tus datos desde '
      'Ajustes.';
  static const String _saveError =
      'No pudimos guardar tu respuesta. Inténtalo de nuevo.';

  bool _accepted = false;
  bool _isSaving = false;

  Future<void> _accept() async {
    setState(() => _isSaving = true);
    try {
      // The router continues to the profile setup when the state changes.
      await ref
          .read(appStateProvider.notifier)
          .acceptPrivacyPolicy(AppInfo.privacyPolicyVersion);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(_saveError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.contentMaxWidth,
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    children: <Widget>[
                      const Center(
                        child: AppLogo(
                          height: AppSizes.logoHeader,
                          framed: true,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        PrivacyConsentPage.title,
                        style: textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(_intro, style: textTheme.bodyLarge),
                      const SizedBox(height: AppSpacing.lg),
                      AppCard(
                        child: Column(
                          children: <Widget>[
                            for (
                              int i = 0;
                              i < PrivacyPolicy.summary.length;
                              i++
                            ) ...<Widget>[
                              if (i > 0) const SizedBox(height: AppSpacing.md),
                              PolicySectionTile(
                                section: PrivacyPolicy.summary[i],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () =>
                              context.push(AppRoutes.privacyPolicy),
                          icon: const Icon(
                            Icons.description_outlined,
                            size: AppSizes.iconSm,
                          ),
                          label: const Text(_readFull),
                        ),
                      ),
                      Text(_revokeNote, style: textTheme.bodySmall),
                    ],
                  ),
                ),
                _ConsentFooter(
                  accepted: _accepted,
                  isSaving: _isSaving,
                  onChanged: (bool value) => setState(() => _accepted = value),
                  onAccept: _accept,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConsentFooter extends StatelessWidget {
  const _ConsentFooter({
    required this.accepted,
    required this.isSaving,
    required this.onChanged,
    required this.onAccept,
  });

  final bool accepted;
  final bool isSaving;
  final ValueChanged<bool> onChanged;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const Border(top: BorderSide(color: AppColors.surfaceVariant)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CheckboxListTile(
              value: accepted,
              onChanged: isSaving ? null : (bool? v) => onChanged(v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: Text(
                PrivacyConsentPage.acceptCheckbox,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: PrivacyConsentPage.acceptButton,
              icon: Icons.arrow_forward_rounded,
              trailingIcon: true,
              expand: true,
              isLoading: isSaving,
              onPressed: accepted ? onAccept : null,
            ),
          ],
        ),
      ),
    );
  }
}
