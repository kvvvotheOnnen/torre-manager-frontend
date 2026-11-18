import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/module_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../core/widgets/top_bar.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import 'modulo_proximamente_screen.dart';

/// Módulo preventivo del conserje (no viene del backend todavía).
class _ModuloConserje {
  const _ModuloConserje({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.ruta,
  });

  final String id;
  final String titulo;
  final String descripcion;
  final IconData icono;
  final String ruta;
}

const _modulosConserje = <_ModuloConserje>[
  _ModuloConserje(
    id: 'solicitudes_residente',
    titulo: 'Gestión de residentes',
    descripcion: 'Aprueba o rechaza solicitudes de nuevos residentes',
    icono: Icons.how_to_reg_outlined,
    ruta: AppRoutes.solicitudesResidente,
  ),
  _ModuloConserje(
    id: 'paqueteria',
    titulo: 'Paquetería',
    descripcion: 'Avisos y retiro de paquetes',
    icono: Icons.inventory_2_outlined,
    ruta: AppRoutes.paqueteriaGestion,
  ),
  _ModuloConserje(
    id: 'control_acceso',
    titulo: 'Control de acceso',
    descripcion: 'Visitantes que entraron y accesos de personas de confianza',
    icono: Icons.badge_outlined,
    ruta: '/admin/modulos/control_acceso',
  ),
  _ModuloConserje(
    id: 'alertas_noticias',
    titulo: 'Alertas y noticias',
    descripcion: 'Comunicados a la comunidad',
    icono: Icons.campaign_outlined,
    ruta: '/admin/modulos/alertas_noticias',
  ),
  _ModuloConserje(
    id: 'instalaciones_extra',
    titulo: 'Reserva de espacios comunes',
    descripcion: 'Reserva de espacios comunes',
    icono: Icons.event_available_outlined,
    ruta: '/admin/modulos/instalaciones_extra',
  ),
];

class ConserjeDashboardScreen extends StatefulWidget {
  const ConserjeDashboardScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<ConserjeDashboardScreen> createState() =>
      _ConserjeDashboardScreenState();
}

class _ConserjeDashboardScreenState extends State<ConserjeDashboardScreen> {
  void _abrirModulo(_ModuloConserje modulo) {
    context.push(
      modulo.ruta,
      extra: ProximamenteArgs(
        titulo: modulo.titulo,
        descripcion: modulo.descripcion,
      ),
    );
  }

  void _notificaciones() {
    context.push(
      AppRoutes.adminModulo('notificaciones'),
      extra: const ProximamenteArgs(
        titulo: 'Notificaciones',
        descripcion: 'Avisos y notificaciones del recinto (próximamente)',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final sections = [
      AppNavSection(
        title: 'Módulos',
        subtitle: 'Herramientas de conserjería',
        items: _modulosConserje
            .map(
              (modulo) => AppNavItem(
                label: modulo.titulo,
                icon: modulo.icono,
                selected: location == modulo.ruta,
                onTap: () => _abrirModulo(modulo),
              ),
            )
            .toList(),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final esEscritorio = constraints.maxWidth >= 900;
        return AppShell(
          sections: sections,
          userName: widget.usuario.nombre,
          roleLabel: widget.usuario.rol.name,
          onLogout: () =>
              context.read<AuthBloc>().add(const LogoutRequested()),
          topBar: AppTopBar(
            greeting: 'Bienvenido, ${widget.usuario.nombre}',
            avatarName: widget.usuario.nombre,
            roleLabel: widget.usuario.rol.name,
            compact: !esEscritorio,
            showThemeToggle: !esEscritorio,
            onLogout: esEscritorio
                ? null
                : () => context.read<AuthBloc>().add(const LogoutRequested()),
            onNotifications: _notificaciones,
          ),
          body: _ContenidoConserje(usuario: widget.usuario),
        );
      },
    );
  }
}

class _ContenidoConserje extends StatelessWidget {
  const _ContenidoConserje({required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth;
        final columnas = ancho >= 1180
            ? 4
            : ancho >= 860
            ? 3
            : ancho >= 560
            ? 2
            : 1;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xxl + MediaQuery.viewPaddingOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroConserje(usuario: usuario),
                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(
                    title: 'Operación diaria',
                    subtitle: 'Accesos rápidos de conserjería',
                    trailing: StatusPill(
                      label: '${_modulosConserje.length} módulos',
                      color: context.palette.primary,
                      compact: true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _modulosConserje.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columnas,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisExtent: 196,
                    ),
                    itemBuilder: (context, index) {
                      final modulo = _modulosConserje[index];
                      return ModuleCard(
                        title: modulo.titulo,
                        description: modulo.descripcion,
                        icon: modulo.icono,
                        onTap: () {
                          context.push(
                            modulo.ruta,
                            extra: ProximamenteArgs(
                              titulo: modulo.titulo,
                              descripcion: modulo.descripcion,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Estos módulos estarán conectados a la operación del recinto.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.palette.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroConserje extends StatelessWidget {
  const _HeroConserje({required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: p.hero,
        borderRadius: AppRadii.xlAll,
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: AppShadows.glow(p.primary),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            bottom: -30,
            child: Icon(
              Icons.support_agent_rounded,
              size: 200,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusPill(
                label: 'CONSERJERÍA',
                color: p.accent,
                icon: Icons.badge_rounded,
                compact: true,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Panel de conserje',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Hola, ${usuario.nombre}. Estos son los módulos disponibles para ti.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: const [
                  _HeroChip(icon: Icons.inventory_2_rounded, label: 'Paquetes'),
                  _HeroChip(icon: Icons.security_rounded, label: 'Accesos'),
                  _HeroChip(icon: Icons.campaign_rounded, label: 'Avisos'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: p.accent),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}
