import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agrokaf/core/app_state/app_state_notifier.dart';
import 'package:agrokaf/core/constants/app_info.dart';
import 'package:agrokaf/core/services/settings_service.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/utils/date_formatter.dart';
import 'package:agrokaf/core/widgets/app_card.dart';
import 'package:agrokaf/features/privacy/domain/privacy_policy.dart';
import 'package:agrokaf/features/privacy/presentation/widgets/policy_section_tile.dart';

/// Full privacy policy, reachable from the consent screen and from Ajustes.
class PrivacyPolicyPage extends ConsumerWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final PrivacyConsent? consent = ref.watch(
      appStateProvider.select((s) => s.consent),
    );
    final List<PolicySection> sections = PrivacyPolicy.sections;

    return Scaffold(
      appBar: AppBar(title: const Text(PrivacyPolicy.title)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: <Widget>[
          Text(
            'Versión ${AppInfo.privacyPolicyVersion} · ${AppInfo.privacyPolicyDate}',
            style: textTheme.bodySmall,
          ),
          if (consent != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            _ConsentBanner(consent: consent),
          ],
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              children: <Widget>[
                for (int i = 0; i < sections.length; i++) ...<Widget>[
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Divider(),
                    ),
                  PolicySectionTile(section: sections[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentBanner extends StatelessWidget {
  const _ConsentBanner({required this.consent});

  final PrivacyConsent consent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.healthyContainer,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.check_circle_rounded, color: AppColors.healthy),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Aceptaste esta política (versión ${consent.policyVersion}) el '
              '${DateFormatter.longDate(consent.acceptedAt)}.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
