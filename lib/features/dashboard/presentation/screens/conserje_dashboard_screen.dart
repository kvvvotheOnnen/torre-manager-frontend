import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/funcion_rutas.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/module_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../core/widgets/top_bar.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/funciones_dashboard_bloc.dart';
import '../widgets/icono_funcion.dart';
import '../../../notificaciones/presentation/bloc/notificaciones_bloc.dart';
import '../../../notificaciones/presentation/screens/notificaciones_screen.dart';

/// Dashboard del conserje.
///
/// Las tarjetas se componen exclusivamente desde `GET /api/dashboard/funciones`;
/// no hay listas de módulos hardcodeadas por rol.
class ConserjeDashboardScreen extends StatefulWidget {
  const ConserjeDashboardScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<ConserjeDashboardScreen> createState() =>
      _ConserjeDashboardScreenState();
}

class _ConserjeDashboardScreenState extends State<ConserjeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FuncionesDashboardBloc>().add(const FuncionesSolicitadas());
  }

  void _notificaciones() {
    NotificacionesDialog.mostrar(context);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final funciones = context.watch<FuncionesDashboardBloc>().state.funciones;

    final sections = [
      AppNavSection(
        title: 'Módulos',
        subtitle: 'Herramientas de conserjería',
        items: funciones
            .map(
              (funcion) => AppNavItem(
                label: funcion.titulo,
                icon: iconoDeFuncion(funcion.icono),
                selected: location == funcion.ruta,
                onTap: () => abrirFuncionDashboard(context, funcion),
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
          onLogout: () => context.read<AuthBloc>().add(const LogoutRequested()),
          topBar: AppTopBar(
            greeting: 'Bienvenido, ${widget.usuario.nombre}',
            avatarName: widget.usuario.nombre,
            roleLabel: widget.usuario.rol.name,
            compact: !esEscritorio,
            showThemeToggle: !esEscritorio,
            onLogout: esEscritorio
                ? null
                : () => context.read<AuthBloc>().add(const LogoutRequested()),
            notificationsCount: context
                .watch<NotificacionesBloc>()
                .state
                .noLeidas,
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
    final state = context.watch<FuncionesDashboardBloc>().state;
    final funciones = state.funciones;

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
            constraints: const BoxConstraints(maxWidth: AppLayout.maxContent),
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
                      label: '${funciones.length} módulos',
                      color: context.palette.primary,
                      compact: true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (state.cargando && funciones.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.tieneError && funciones.isEmpty)
                    AppEmptyState(
                      icon: Icons.cloud_off_rounded,
                      title: 'No pudimos cargar tus módulos',
                      message:
                          state.mensaje ??
                          'Revisa tu conexión e inténtalo de nuevo.',
                      actionLabel: 'Reintentar',
                      onAction: () => context
                          .read<FuncionesDashboardBloc>()
                          .add(const FuncionesRefrescadas()),
                    )
                  else if (funciones.isEmpty)
                    const AppEmptyState(
                      icon: Icons.widgets_outlined,
                      title: 'Aún no tienes módulos disponibles',
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: funciones.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columnas,
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisExtent: 196,
                      ),
                      itemBuilder: (context, index) {
                        final funcion = funciones[index];
                        return ModuleCard(
                          title: funcion.titulo,
                          description: funcion.descripcion,
                          icon: iconoDeFuncion(funcion.icono),
                          onTap: () => abrirFuncionDashboard(context, funcion),
                        );
                      },
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Cada módulo aparece según los permisos y la configuración del recinto.',
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
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Colors.white.withValues(alpha: 0.88)),
          ),
        ],
      ),
    );
  }
}
