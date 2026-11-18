import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';
import '../theme/theme_mode_controller.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.greeting,
    required this.avatarName,
    this.roleLabel,
    this.selector,
    this.compact = false,
    this.notificationsCount = 0,
    this.onNotifications,
    this.onLogout,
    this.leading,
    this.showThemeToggle = true,
  });

  final String greeting;
  final String avatarName;
  final String? roleLabel;
  final Widget? selector;
  final bool compact;
  final int notificationsCount;
  final VoidCallback? onNotifications;
  final VoidCallback? onLogout;
  final Widget? leading;
  final bool showThemeToggle;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final theme = Theme.of(context);

    final greetingBlock = Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: AppSpacing.md)],
        AvatarBadge(name: avatarName),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              if (roleLabel != null)
                Text(
                  roleLabel!.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: p.inkMuted,
                    letterSpacing: 1.1,
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showThemeToggle) const ThemeToggleButton(),
        if (onNotifications != null)
          NotificationButton(
            count: notificationsCount,
            onPressed: onNotifications!,
          ),
        if (onLogout != null)
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded, size: 20),
            onPressed: onLogout,
          ),
      ],
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.lg : AppSpacing.xl,
        vertical: compact ? AppSpacing.md : AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: p.surface.withValues(alpha: p.isDark ? 0.74 : 0.78),
        border: Border(bottom: BorderSide(color: p.border)),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: greetingBlock),
                    const SizedBox(width: AppSpacing.sm),
                    actions,
                  ],
                ),
                if (selector != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  selector!,
                ],
              ],
            )
          : Row(
              children: [
                Expanded(flex: 3, child: greetingBlock),
                if (selector != null) ...[
                  const SizedBox(width: AppSpacing.xl),
                  SizedBox(width: 280, child: selector!),
                ],
                const Spacer(),
                actions,
              ],
            ),
    );
  }
}

class AvatarBadge extends StatelessWidget {
  const AvatarBadge({super.key, required this.name, this.size = 42});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: p.brand,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class NotificationButton extends StatelessWidget {
  const NotificationButton({
    super.key,
    required this.count,
    required this.onPressed,
  });

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      tooltip: 'Notificaciones',
      icon: const Icon(Icons.notifications_outlined, size: 20),
      onPressed: onPressed,
    );
    if (count <= 0) return button;
    return Badge(label: Text('$count'), child: button);
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final controller = ThemeModeScope.maybeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      tooltip: isDark ? 'Cambiar a tema claro' : 'Cambiar a tema oscuro',
      icon: Icon(
        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        size: 20,
        color: p.ink,
      ),
      onPressed: controller == null ? null : () => controller.toggle(Theme.of(context).brightness),
    );
  }
}

class ProjectOption {
  const ProjectOption({required this.id, required this.nombre});

  final String id;
  final String nombre;
}

class AppProjectSelector extends StatelessWidget {
  const AppProjectSelector({
    super.key,
    required this.projects,
    required this.value,
    required this.onChanged,
  });

  final List<ProjectOption> projects;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          Icon(Icons.apartment_rounded, size: 18, color: p.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PROYECTO ACTIVO',
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.1,
                    color: p.inkMuted,
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    isDense: true,
                    borderRadius: AppRadii.mdAll,
                    dropdownColor: p.surface,
                    icon: Icon(Icons.expand_more_rounded, color: p.inkMuted),
                    style: theme.textTheme.bodyMedium?.copyWith(color: p.ink),
                    items: projects
                        .map(
                          (project) => DropdownMenuItem<String>(
                            value: project.id,
                            child: Text(
                              project.nombre,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (id) {
                      if (id == null || id == value) return;
                      onChanged(id);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
