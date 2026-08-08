import 'package:flutter/material.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';

enum PillButtonVariant { filled, text }

class PrimaryPillButton extends StatefulWidget {
  const PrimaryPillButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.variant = PillButtonVariant.filled,
    this.backgroundColor,
    this.foregroundColor,
    this.hoverBackgroundColor,
    this.padding,
    this.borderRadius,
    this.showShadow = true,
    this.isLoading = false,
    this.loadingLabel,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final PillButtonVariant variant;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? hoverBackgroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final bool showShadow;
  final bool isLoading;
  final String? loadingLabel;

  @override
  State<PrimaryPillButton> createState() => _PrimaryPillButtonState();
}

class _PrimaryPillButtonState extends State<PrimaryPillButton> {
  static const double _activeScale = 0.95;
  static const double _hoverOpacity = 0.90;
  static const double _indicatorSize = 18;

  double _currentScale = 1.0;
  double _currentOpacity = 1.0;
  bool _isHovering = false;

  Color get _baseBgColor {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    return switch (widget.variant) {
      PillButtonVariant.filled => AppColors.primaryContainer,
      PillButtonVariant.text => Colors.transparent,
    };
  }

  Color get _fgColor {
    if (widget.foregroundColor != null) return widget.foregroundColor!;
    return switch (widget.variant) {
      PillButtonVariant.filled => AppColors.onPrimaryContainer,
      PillButtonVariant.text => AppColors.onSurfaceVariant,
    };
  }

  Color get _hoverBgColor {
    if (widget.hoverBackgroundColor != null) {
      return widget.hoverBackgroundColor!;
    }
    if (widget.variant == PillButtonVariant.text) {
      return AppColors.surfaceVariant;
    }
    return _baseBgColor;
  }

  EdgeInsetsGeometry get _padding =>
      widget.padding ??
      const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      );

  BorderRadiusGeometry get _borderRadius =>
      widget.borderRadius ?? BorderRadius.circular(AppSpacing.radiusFull);

  VoidCallback? get _effectiveOnTap {
    if (widget.isLoading) return null;
    return widget.onTap;
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle =
        Theme.of(context).textTheme.labelMedium?.copyWith(
              color: _fgColor,
              fontWeight: FontWeight.w500,
            ) ??
        TextStyle(
          fontSize: 12,
          height: 16 / 12,
          letterSpacing: 0.1,
          fontWeight: FontWeight.w500,
          color: _fgColor,
        );

    final Color effectiveBgColor = _isHovering ? _hoverBgColor : _baseBgColor;

    return MouseRegion(
      onEnter: (_) => _applyHover(true),
      onExit: (_) => _applyHover(false),
      child: GestureDetector(
        onTapDown: _effectiveOnTap == null ? null : (_) => _applyPressed(true),
        onTapUp: _effectiveOnTap == null ? null : (_) => _applyPressed(false),
        onTapCancel:
            _effectiveOnTap == null ? null : () => _applyPressed(false),
        onTap: _effectiveOnTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _currentScale,
          duration: AppAnimations.fast,
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: _currentOpacity,
            duration: AppAnimations.fast,
            child: AbsorbPointer(
              absorbing: widget.isLoading,
              child: AnimatedContainer(
                duration: AppAnimations.fast,
                curve: Curves.easeOut,
                padding: _padding,
                decoration: BoxDecoration(
                  color: effectiveBgColor,
                  borderRadius: _borderRadius,
                  boxShadow:
                      widget.variant == PillButtonVariant.filled &&
                              widget.showShadow
                          ? AppShadows.buttonSm
                          : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (widget.isLoading) ...<Widget>[
                      SizedBox(
                        width: _indicatorSize,
                        height: _indicatorSize,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(_fgColor),
                        ),
                      ),
                      if (widget.loadingLabel != null &&
                          widget.loadingLabel!.isNotEmpty) ...<Widget>[
                        const SizedBox(width: AppSpacing.sm),
                        Text(widget.loadingLabel!, style: labelStyle),
                      ],
                    ] else ...<Widget>[
                      Text(widget.label, style: labelStyle),
                      if (widget.icon != null) ...<Widget>[
                        const SizedBox(width: AppSpacing.xs),
                        Icon(widget.icon, size: 18, color: _fgColor),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _applyHover(bool isHovering) {
    if (!mounted) return;
    setState(() {
      _isHovering = isHovering;
      _currentOpacity = isHovering ? _hoverOpacity : 1.0;
    });
  }

  void _applyPressed(bool isPressed) {
    if (!mounted) return;
    setState(() {
      _currentScale = isPressed ? _activeScale : 1.0;
    });
  }
}
