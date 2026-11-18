import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.borderRadius,
    this.onTap,
    this.blur = 18,
    this.glowColor,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final double blur;
  final Color? glowColor;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final radius = borderRadius ?? AppRadii.xlAll;
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: gradient == null
            ? p.surface.withValues(alpha: p.isDark ? 0.72 : 0.82)
            : null,
        gradient: gradient,
        border: Border.all(
          color: p.border.withValues(alpha: p.isDark ? 0.9 : 0.8),
        ),
        boxShadow: glowColor == null
            ? AppShadows.soft(p.isDark)
            : AppShadows.glow(glowColor!),
      ),
      child: child,
    );

    final clipped = ClipRRect(
      borderRadius: radius,
      child: blur > 0
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: content,
            )
          : content,
    );

    if (onTap == null) return clipped;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: clipped,
      ),
    );
  }
}
