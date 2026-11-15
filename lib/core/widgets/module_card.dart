import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';

class ModuleCard extends StatefulWidget {
  const ModuleCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.enabled = true,
    this.lockedText = 'No habilitado para este proyecto.',
    this.accent,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final String lockedText;
  final Color? accent;

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final accent = widget.accent ?? p.primary;
    final enabled = widget.enabled;
    final textColor = enabled ? p.ink : p.inkMuted;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: '${widget.title}. ${enabled ? widget.description : widget.lockedText}',
        child: AnimatedContainer(
          duration: AppDurations.base,
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _hovered && enabled ? -4 : 0, 0),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: AppRadii.lgAll,
            border: Border.all(
              color: _hovered && enabled
                  ? accent.withValues(alpha: 0.55)
                  : p.border,
            ),
            boxShadow: _hovered && enabled
                ? AppShadows.lift(p.isDark)
                : AppShadows.soft(p.isDark),
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (enabled) {
                  HapticFeedback.selectionClick();
                } else {
                  HapticFeedback.lightImpact();
                }
                widget.onTap();
              },
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: enabled
                            ? LinearGradient(colors: [accent, p.accent])
                            : LinearGradient(
                                colors: [p.border, p.border],
                              ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _IconTile(
                              icon: widget.icon,
                              enabled: enabled,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: enabled
                                    ? [accent, p.primaryDeep]
                                    : [p.surfaceStrong, p.surfaceStrong],
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              enabled
                                  ? Icons.arrow_outward_rounded
                                  : Icons.lock_outline,
                              size: 20,
                              color: enabled ? p.inkMuted : p.inkMuted,
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          widget.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          enabled ? widget.description : widget.lockedText,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.enabled,
    required this.gradient,
  });

  final IconData icon;
  final bool enabled;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: AppRadii.mdAll,
        border: Border.all(
          color: Colors.white.withValues(alpha: enabled ? 0.16 : 0.04),
        ),
      ),
      child: Icon(
        icon,
        size: 24,
        color: enabled ? Colors.white : p.inkMuted,
      ),
    );
  }
}
