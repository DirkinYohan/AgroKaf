import 'package:flutter/material.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';

class CameraFrameOverlay extends StatelessWidget {
  const CameraFrameOverlay({super.key});

  static const double _cornerSize = 48;
  static const double _cornerStroke = 4;
  static const double _cornerRadius = 8;
  static const double _fabPrimarySize = 56;
  static const double _fabPrimaryIcon = 32;
  static const double _fabSecondarySize = 48;
  static const double _fabSecondaryIcon = 24;
  static const double _fabBadgeSize = 20;
  static const double _fabBadgeIcon = 16;
  static const double _fabGap = 16;
  static const double _fabBottom = 32;
  static const double _fabShadowRadius = 12;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _buildTopBar(),
        _buildFocusBrackets(),
        _buildBottomFabs(),
      ],
    );
  }

  Widget _buildTopBar() {
    const double top = AppSpacing.base;
    return Stack(
      children: <Widget>[
        Positioned(
          top: top,
          left: AppSpacing.base,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(width: _cornerRadius),
              Icon(Icons.flash_off, color: AppColors.primary),
            ],
          ),
        ),
        Positioned(
          top: top,
          right: AppSpacing.base,
          child: Icon(Icons.close, color: AppColors.primary),
        ),
        Positioned(
          top: top,
          left: 0,
          right: 0,
          child: Center(child: Icon(Icons.settings, color: AppColors.primary)),
        ),
      ],
    );
  }

  Widget _buildFocusBrackets() {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 0,
          left: 0,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double offX = constraints.maxWidth * 0.25;
              final double offY = constraints.maxHeight * 0.25;
              return Padding(
                padding: EdgeInsets.only(left: offX, top: offY),
                child: _buildCorner(top: true, left: true),
              );
            },
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double offX = constraints.maxWidth * 0.25;
              final double offY = constraints.maxHeight * 0.25;
              return Padding(
                padding: EdgeInsets.only(right: offX, top: offY),
                child: _buildCorner(top: true, left: false),
              );
            },
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double offX = constraints.maxWidth * 0.25;
              final double offY = constraints.maxHeight * 0.25;
              return Padding(
                padding: EdgeInsets.only(left: offX, bottom: offY),
                child: _buildCorner(top: false, left: true),
              );
            },
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double offX = constraints.maxWidth * 0.25;
              final double offY = constraints.maxHeight * 0.25;
              return Padding(
                padding: EdgeInsets.only(right: offX, bottom: offY),
                child: _buildCorner(top: false, left: false),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCorner({required bool top, required bool left}) {
    const Color c = AppColors.secondary;
    const double s = _cornerStroke;
    const double size = _cornerSize;

    final BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: top && left ? const Radius.circular(_cornerRadius) : Radius.zero,
      topRight: top && !left
          ? const Radius.circular(_cornerRadius)
          : Radius.zero,
      bottomLeft: !top && left
          ? const Radius.circular(_cornerRadius)
          : Radius.zero,
      bottomRight: !top && !left
          ? const Radius.circular(_cornerRadius)
          : Radius.zero,
    );

    final BoxBorder border = Border(
      top: top ? BorderSide(color: c, width: s) : BorderSide.none,
      bottom: !top ? BorderSide(color: c, width: s) : BorderSide.none,
      left: left ? BorderSide(color: c, width: s) : BorderSide.none,
      right: !left ? BorderSide(color: c, width: s) : BorderSide.none,
    );

    return SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(border: border, borderRadius: radius),
      ),
    );
  }

  Widget _buildBottomFabs() {
    return Positioned(
      bottom: _fabBottom,
      left: 0,
      right: 0,
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _Fab(
                size: _fabPrimarySize,
                color: AppColors.primaryContainer,
                foreground: AppColors.onPrimaryContainer,
                icon: Icons.photo_camera,
                iconSize: _fabPrimaryIcon,
                shadow: _fabShadow(),
                scale: 1.05,
              ),
              const SizedBox(width: _fabGap),
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  _Fab(
                    size: _fabSecondarySize,
                    color: AppColors.secondary,
                    foreground: AppColors.onSecondary,
                    icon: Icons.image,
                    iconSize: _fabSecondaryIcon,
                    shadow: AppShadows.cardSm,
                    scale: 1.05,
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: _fabBadgeSize,
                      height: _fabBadgeSize,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.north_east,
                        size: _fabBadgeIcon,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<BoxShadow> _fabShadow() => <BoxShadow>[
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: _fabShadowRadius,
      offset: const Offset(0, 4),
    ),
  ];
}

class _Fab extends StatelessWidget {
  const _Fab({
    required this.size,
    required this.color,
    required this.foreground,
    required this.icon,
    required this.iconSize,
    required this.shadow,
    required this.scale,
  });

  final double size;
  final Color color;
  final Color foreground;
  final IconData icon;
  final double iconSize;
  final List<BoxShadow> shadow;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: shadow,
        ),
        child: Icon(icon, color: foreground, size: iconSize),
      ),
    );
  }
}
