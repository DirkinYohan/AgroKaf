import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agrokaf/core/constants/app_routes.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/widgets/app_button.dart';
import 'package:agrokaf/core/widgets/app_card.dart';
import 'package:agrokaf/core/widgets/state_views.dart';
import 'package:agrokaf/core/widgets/user_avatar.dart';
import 'package:agrokaf/features/profile/domain/entities/user_profile.dart';
import 'package:agrokaf/features/profile/presentation/providers/profile_providers.dart';

/// "Perfil" tab: the user's data and the entry point to settings.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static const String _title = 'Perfil';
  static const String _editLabel = 'Editar perfil';
  static const String _settingsLabel = 'Ajustes';
  static const String _loadError = 'No pudimos cargar tu perfil.';
  static const String _noProfileTitle = 'Aún no tienes perfil';
  static const String _noProfileMessage =
      'Crea tu perfil para personalizar AgroKaf.';
  static const String _createLabel = 'Crear perfil';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UserProfile?> profile = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(_title),
        actions: <Widget>[
          IconButton(
            tooltip: _settingsLabel,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: profile.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(
          message: _loadError,
          onRetry: () => ref.invalidate(profileProvider),
        ),
        data: (UserProfile? data) => data == null
            ? EmptyState(
                icon: Icons.person_add_alt_1_rounded,
                title: _noProfileTitle,
                message: _noProfileMessage,
                actionLabel: _createLabel,
                onAction: () => context.push(AppRoutes.profileEdit),
              )
            : _ProfileContent(profile: data),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.profile});

  static const String _farm = 'Finca';
  static const String _municipality = 'Municipio';
  static const String _variety = 'Variedad de café';
  static const String _empty = 'Sin dato';

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: <Widget>[
        Center(
          child: UserAvatar(
            imagePath: profile.profileImagePath,
            name: profile.userName,
            size: AppSizes.avatarLg,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          profile.userName,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            children: <Widget>[
              _InfoRow(
                icon: Icons.agriculture_outlined,
                label: _farm,
                value: profile.farmName,
              ),
              const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: _municipality,
                value: profile.municipality,
              ),
              const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
              _InfoRow(
                icon: Icons.eco_outlined,
                label: _variety,
                value: profile.coffeeVariety,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: ProfilePage._editLabel,
          icon: Icons.edit_outlined,
          variant: AppButtonVariant.secondary,
          expand: true,
          onPressed: () => context.push(AppRoutes.profileEdit),
        ),
      ],
    );
  }

  static String _orEmpty(String value) => value.trim().isEmpty ? _empty : value;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: Theme.of(context).textTheme.bodySmall),
      subtitle: Text(
        _ProfileContent._orEmpty(value),
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}
