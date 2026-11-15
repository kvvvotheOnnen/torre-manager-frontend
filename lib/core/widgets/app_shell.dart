import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';
import 'brand_mark.dart';
import 'section_header.dart';
import 'top_bar.dart';

class AppNavItem {
  const AppNavItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.selected = false,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;
  final bool enabled;
}

class AppNavSection {
  const AppNavSection({
    required this.title,
    required this.items,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<AppNavItem> items;
}

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.sections,
    required this.topBar,
    required this.body,
    required this.userName,
    required this.roleLabel,
    this.onLogout,
    this.brandSubtitle = 'ADMINISTRACIÓN DE CONDOMINIOS',
  });

  final List<AppNavSection> sections;
  final Widget topBar;
  final Widget body;
  final String userName;
  final String roleLabel;
  final VoidCallback? onLogout;
  final String brandSubtitle;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        if (isDesktop) {
          return Scaffold(
            backgroundColor: p.background,
            body: Row(
              children: [
                _Sidebar(
                  sections: sections,
                  userName: userName,
                  roleLabel: roleLabel,
                  onLogout: onLogout,
                  brandSubtitle: brandSubtitle,
                ),
                Expanded(
                  child: Column(
                    children: [
                      topBar,
                      Expanded(child: body),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: p.background,
          appBar: AppBar(
            backgroundColor: p.surface,
            surfaceTintColor: Colors.transparent,
            titleSpacing: AppSpacing.lg,
            title: BrandMark(size: 34, showWordmark: true),
            actions: const [SizedBox(width: AppSpacing.sm)],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: p.border),
            ),
          ),
          drawer: Drawer(
            width: 300,
            backgroundColor: p.surface,
            child: SafeArea(
              child: _SidebarContent(
                sections: sections,
                userName: userName,
                roleLabel: roleLabel,
                onLogout: onLogout,
                brandSubtitle: brandSubtitle,
                esDrawer: true,
              ),
            ),
          ),
          body: Column(
            children: [
              topBar,
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.sections,
    required this.userName,
    required this.roleLabel,
    required this.onLogout,
    required this.brandSubtitle,
  });

  final List<AppNavSection> sections;
  final String userName;
  final String roleLabel;
  final VoidCallback? onLogout;
  final String brandSubtitle;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: 292,
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(right: BorderSide(color: p.border)),
      ),
      child: SafeArea(
        right: false,
        child: _SidebarContent(
          sections: sections,
          userName: userName,
          roleLabel: roleLabel,
          onLogout: onLogout,
          brandSubtitle: brandSubtitle,
        ),
      ),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  const _SidebarContent({
    required this.sections,
    required this.userName,
    required this.roleLabel,
    required this.onLogout,
    required this.brandSubtitle,
    this.esDrawer = false,
  });

  final List<AppNavSection> sections;
  final String userName;
  final String roleLabel;
  final VoidCallback? onLogout;
  final String brandSubtitle;
  final bool esDrawer;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: BrandMark(
            size: 44,
            showWordmark: true,
            subtitle: brandSubtitle,
          ),
        ),
        Container(height: 1, color: p.border),
        Expanded(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            children: [
              for (final section in sections) ...[
                SectionHeader(title: section.title, subtitle: section.subtitle),
                const SizedBox(height: AppSpacing.xs),
                for (final item in section.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: _SidebarItem(item: item, esDrawer: esDrawer),
                  ),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        ),
        Container(height: 1, color: p.border),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              AvatarBadge(name: userName, size: 40),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      roleLabel.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: p.inkMuted,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const ThemeToggleButton(),
              if (onLogout != null)
                IconButton(
                  tooltip: 'Cerrar sesión',
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  onPressed: onLogout,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({required this.item, required this.esDrawer});

  final AppNavItem item;
  final bool esDrawer;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final selected = item.selected;
    final color = item.enabled ? p.ink : p.inkMuted.withValues(alpha: 0.7);

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadii.mdAll,
          onTap: () {
            if (item.enabled) {
              HapticFeedback.selectionClick();
            }
            if (esDrawer) {
              Scaffold.maybeOf(context)?.closeDrawer();
            }
            item.onTap();
          },
          child: AnimatedContainer(
            duration: AppDurations.fast,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadii.mdAll,
              gradient: selected
                  ? LinearGradient(
                      colors: [
                        p.primary.withValues(alpha: 0.16),
                        p.primary.withValues(alpha: 0.02),
                      ],
                    )
                  : null,
              border: Border.all(
                color: selected
                    ? p.primary.withValues(alpha: 0.25)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: AppDurations.fast,
                  width: 3,
                  height: 18,
                  margin: const EdgeInsets.only(right: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: selected ? p.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Icon(
                  item.icon,
                  size: 20,
                  color: selected
                      ? p.primary
                      : item.enabled
                      ? p.inkMuted
                      : p.inkMuted.withValues(alpha: 0.6),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    item.label,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (!item.enabled)
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: p.inkMuted.withValues(alpha: 0.7),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
