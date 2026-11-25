import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_content.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/module_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../core/widgets/top_bar.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../tenant/presentation/bloc/tenant_bloc.dart';
import '../../domain/entities/modulo_dashboard.dart';
import '../bloc/modulos_dashboard_bloc.dart';
import 'modulo_proximamente_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final proyectoId = context.read<TenantBloc>().state.proyectoActivoId;
      if (proyectoId != null) {
        context.read<ModulosDashboardBloc>().add(
          const ModulosDashboardSolicitados(),
        );
      }
    });
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
    return BlocListener<TenantBloc, TenantState>(
      listenWhen: (previous, current) =>
          previous.proyectoActivoId != current.proyectoActivoId &&
          current.proyectoActivoId != null,
      listener: (context, state) {
        context.read<ModulosDashboardBloc>().add(
          const ModulosDashboardSolicitados(),
        );
      },
      child: BlocBuilder<TenantBloc, TenantState>(
        builder: (context, tenantState) {
          if (tenantState.status == TenantStatus.inicial ||
              tenantState.status == TenantStatus.cargando) {
            return const _EstadoDashboardCargando();
          }

          final proyecto = tenantState.proyectoActivo;
          if (proyecto == null) {
            return _EstadoDashboard(
              child: AppEmptyState(
                icon: Icons.domain_disabled_rounded,
                title: 'Sin proyectos asignados',
                message:
                    tenantState.mensaje ??
                    'No tienes proyectos asignados para administrar.',
                actionLabel: 'Reintentar',
                onAction: () =>
                    context.read<TenantBloc>().add(const TenantResuelto()),
              ),
            );
          }

          final modulosState = context.watch<ModulosDashboardBloc>().state;
          final location = GoRouterState.of(context).matchedLocation;

          return LayoutBuilder(
            builder: (context, constraints) {
              final esEscritorio = constraints.maxWidth >= 900;
              final sections = _construirSecciones(
                modulosState: modulosState,
                location: location,
              );

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
                      : () => context.read<AuthBloc>().add(
                          const LogoutRequested(),
                        ),
                  onNotifications: _notificaciones,
                  selector: AppProjectSelector(
                    projects: tenantState.proyectos
                        .map(
                          (proyecto) => ProjectOption(
                            id: proyecto.id,
                            nombre: proyecto.nombre,
                          ),
                        )
                        .toList(),
                    value: tenantState.proyectoActivoId,
                    onChanged: (id) => context.read<TenantBloc>().add(
                      TenantProyectoSeleccionado(id),
                    ),
                  ),
                ),
                body: _ContenidoDashboard(
                  usuario: widget.usuario,
                  proyectoNombre: proyecto.nombre,
                  modulosState: modulosState,
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<AppNavSection> _construirSecciones({
    required ModulosDashboardState modulosState,
    required String location,
  }) {
    final sections = <AppNavSection>[];

    if (modulosState.modulosProyecto.isNotEmpty) {
      sections.add(
        AppNavSection(
          title: 'Módulos del proyecto',
          items: modulosState.modulosProyecto
              .map((modulo) => _navItem(modulo, location))
              .toList(),
        ),
      );
    }

    if (modulosState.modulosGenerales.isNotEmpty) {
      sections.add(
        AppNavSection(
          title: 'Módulos generales',
          items: modulosState.modulosGenerales
              .map((modulo) => _navItem(modulo, location))
              .toList(),
        ),
      );
    }

    return sections;
  }

  AppNavItem _navItem(ModuloDashboard modulo, String location) {
    return AppNavItem(
      label: modulo.nombre,
      icon: _iconoPara(modulo.id),
      enabled: modulo.habilitado,
      selected: location == _rutaPara(modulo),
      onTap: () => _abrirModulo(context, modulo),
    );
  }
}

class _EstadoDashboardCargando extends StatelessWidget {
  const _EstadoDashboardCargando();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppBackground(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: p.accent),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Preparando tu panel…',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: p.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoDashboard extends StatelessWidget {
  const _EstadoDashboard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppBackground(child: SafeArea(child: child));
  }
}

class _ContenidoDashboard extends StatelessWidget {
  const _ContenidoDashboard({
    required this.usuario,
    required this.proyectoNombre,
    required this.modulosState,
  });

  final Usuario usuario;
  final String proyectoNombre;
  final ModulosDashboardState modulosState;

  @override
  Widget build(BuildContext context) {
    if (modulosState.status == ModulosDashboardStatus.cargando &&
        modulosState.modulos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (modulosState.status == ModulosDashboardStatus.error &&
        modulosState.modulos.isEmpty) {
      return AppEmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'No pudimos cargar tus módulos',
        message:
            modulosState.mensaje ?? 'Revisa tu conexión e inténtalo de nuevo.',
        actionLabel: 'Reintentar',
        onAction: () => context.read<ModulosDashboardBloc>().add(
          const ModulosDashboardSolicitados(),
        ),
      );
    }

    final modulos = modulosState.modulos;
    final habilitados = modulos.where((m) => m.habilitado).length;

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

        return AppContent(
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
                _HeroPanel(
                  usuario: usuario,
                  proyectoNombre: proyectoNombre,
                  totalModulos: modulos.length,
                  habilitados: habilitados,
                ),
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(
                  title: 'Módulos disponibles',
                  subtitle: 'Accesos habilitados para este recinto',
                  trailing: StatusPill(
                    label: '$habilitados/${modulos.length} activos',
                    color: habilitados == modulos.length
                        ? context.palette.success
                        : context.palette.accent,
                    compact: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (modulos.isEmpty)
                  AppEmptyState(
                    icon: Icons.widgets_outlined,
                    title: 'Aún no hay módulos',
                    message:
                        'Este proyecto todavía no tiene módulos configurados.',
                    actionLabel: 'Actualizar',
                    onAction: () => context.read<ModulosDashboardBloc>().add(
                      const ModulosDashboardSolicitados(),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: modulos.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columnas,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisExtent: 196,
                    ),
                    itemBuilder: (context, index) {
                      final modulo = modulos[index];
                      return ModuleCard(
                        title: modulo.nombre,
                        description: modulo.descripcion,
                        icon: _iconoPara(modulo.id),
                        enabled: modulo.habilitado,
                        onTap: () => _abrirModulo(context, modulo),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.usuario,
    required this.proyectoNombre,
    required this.totalModulos,
    required this.habilitados,
  });

  final Usuario usuario;
  final String proyectoNombre;
  final int totalModulos;
  final int habilitados;

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
            right: -30,
            top: -40,
            child: Icon(
              Icons.apartment_rounded,
              size: 220,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusPill(
                label: 'PROYECTO ACTIVO',
                color: p.accent,
                icon: Icons.place_rounded,
                compact: true,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Panel de $proyectoNombre',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Hola, ${usuario.nombre}. Estos son los módulos disponibles para este proyecto.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _HeroStat(
                    icon: Icons.grid_view_rounded,
                    value: '$totalModulos',
                    label: 'módulos',
                  ),
                  _HeroStat(
                    icon: Icons.check_circle_outline_rounded,
                    value: '$habilitados',
                    label: 'habilitados',
                  ),
                  _HeroStat(
                    icon: Icons.lock_outline_rounded,
                    value: '${totalModulos - habilitados}',
                    label: 'bloqueados',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
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
          Icon(icon, size: 16, color: p.accent),
          const SizedBox(width: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: Colors.white),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Colors.white.withValues(alpha: 0.72)),
          ),
        ],
      ),
    );
  }
}

void _abrirModulo(BuildContext context, ModuloDashboard modulo) {
  if (!modulo.habilitado) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Este módulo no está habilitado para el proyecto.'),
        ),
      );
    return;
  }

  final scaffold = Scaffold.maybeOf(context);
  if (scaffold?.isDrawerOpen ?? false) {
    scaffold!.closeDrawer();
  }

  final ruta = _rutaPara(modulo);
  if (GoRouterState.of(context).matchedLocation == ruta) return;
  context.push(ruta);
}

String _rutaPara(ModuloDashboard modulo) {
  if (modulo.id == 'solicitudes_residente') {
    return AppRoutes.solicitudesResidente;
  }

  return AppRoutes.adminModulo(modulo.id);
}

IconData _iconoPara(String id) {
  return switch (id) {
    'paqueteria' => Icons.inventory_2_outlined,
    'instalaciones_extra' => Icons.event_available_outlined,
    'gastos_comunes' => Icons.receipt_long,
    'control_acceso' => Icons.security,
    'registro_conserjes' => Icons.badge_outlined,
    'cambio_unidad_residente' => Icons.swap_horiz,
    'solicitudes_residente' => Icons.how_to_reg_outlined,
    'registro_empleados' => Icons.cleaning_services_outlined,
    'personas_externas_oficios' => Icons.engineering_outlined,
    'alertas_noticias' => Icons.campaign_outlined,
    'asistente_ia_admin' => Icons.cloud_upload_outlined,
    'servicios_recomendados' => Icons.handyman_outlined,
    'marketplace' => Icons.storefront_outlined,
    _ => Icons.widgets_outlined,
  };
}
