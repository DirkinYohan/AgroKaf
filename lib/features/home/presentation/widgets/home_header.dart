import 'package:flutter/material.dart';

import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/widgets/user_avatar.dart';

/// Greeting row: avatar (opens the profile) + name + settings gear.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.onAvatarTap,
    required this.onSettingsTap,
    this.name,
    this.imagePath,
  });

  static const String _greetingFallback = '¡Hola!';
  static const String _subtitle = '¿Qué planta revisamos hoy?';
  static const String _profileTooltip = 'Ver mi perfil';
  static const String _settingsTooltip = 'Ajustes';

  final String? name;
  final String? imagePath;
  final VoidCallback onAvatarTap;
  final VoidCallback onSettingsTap;

  String get _greeting {
    final String firstName = (name ?? '').trim().split(' ').first;
    return firstName.isEmpty ? _greetingFallback : '¡Hola, $firstName!';
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      children: <Widget>[
        Tooltip(
          message: _profileTooltip,
          child: InkResponse(
            onTap: onAvatarTap,
            radius: AppSizes.avatarSm / 2 + AppSpacing.xs,
            child: UserAvatar(imagePath: imagePath, name: name),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _greeting,
                style: textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(_subtitle, style: textTheme.bodyMedium),
            ],
          ),
        ),
        IconButton(
          tooltip: _settingsTooltip,
          icon: const Icon(Icons.settings_outlined),
          onPressed: onSettingsTap,
        ),
      ],
    );
  }
}
