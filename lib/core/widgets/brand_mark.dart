import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/design_tokens.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 44,
    this.showWordmark = false,
    this.subtitle,
    this.onTap,
  });

  final double size;
  final bool showWordmark;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: p.brand,
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: AppShadows.glow(p.primary),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.apartment_rounded,
            size: size * 0.56,
            color: Colors.white,
          ),
          Positioned(
            bottom: size * 0.13,
            child: Container(
              width: size * 0.26,
              height: 3,
              decoration: BoxDecoration(
                color: p.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );

    if (!showWordmark) {
      return Semantics(
        label: 'Torre Manager',
        button: onTap != null,
        child: onTap == null
            ? mark
            : GestureDetector(onTap: onTap, child: mark),
      );
    }

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Torre Manager',
          style: AppTypography.textTheme(
            p.brightness,
            p.ink,
            p.inkMuted,
          ).titleLarge?.copyWith(letterSpacing: -0.4),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: p.inkMuted,
              letterSpacing: 1.4,
            ),
          ),
      ],
    );

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.mdAll,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          mark,
          const SizedBox(width: AppSpacing.md),
          Flexible(child: text),
        ],
      ),
    );
  }
}
