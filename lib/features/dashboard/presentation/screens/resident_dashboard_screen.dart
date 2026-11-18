import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/router/funcion_rutas.dart';
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
import '../bloc/funciones_dashboard_bloc.dart';
import '../widgets/icono_funcion.dart';
import 'modulo_proximamente_screen.dart';

/// Módulo preventivo del residente (no viene del backend todavía).
class _ModuloResidente {
  const _ModuloResidente({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.ruta,
    this.preventivo = true,
  });

  final String id;
  final String titulo;
  final String descripcion;
  final IconData icono;
  final String ruta;
  final bool preventivo;
}

const _modulosResidente = <_ModuloResidente>[
  _ModuloResidente(
    id: 'mi_informacion',
    titulo: 'Mi información',
    descripcion:
        'Consulta la información que ya es del residente y asignaciones de servicio',
    icono: Icons.home_outlined,
    ruta: '/residente/mi-informacion',
    preventivo: false,
  ),
  _ModuloResidente(
    id: 'ia',
    titulo: 'IA',
    descripcion: 'Consultas sobre el reglamento de infraestructura del edificio',
    icono: Icons.star,
    ruta: '/residente/ia',
    preventivo: false,
  ),
  _ModuloResidente(
    id: 'paqueteria',
    titulo: 'Paquetería',
    descripcion: 'Avisos y retiro de paquetes',
    icono: Icons.inventory_2_outlined,
    ruta: AppRoutes.paqueteria,
    preventivo: false,
  ),
  _ModuloResidente(
    id: 'quincho',
    titulo: 'Quincho',
    descripcion: 'Reserva de espacios comunes',
    icono: Icons.event_available_outlined,
    ruta: '/admin/modulos/quincho',
  ),
  _ModuloResidente(
    id: 'gastos_comunes',
    titulo: 'Gastos comunes',
    descripcion: 'Consulta y pago de gastos comunes',
    icono: Icons.receipt_long_outlined,
    ruta: '/admin/modulos/gastos_comunes',
  ),
  _ModuloResidente(
    id: 'control_acceso',
    titulo: 'Control de acceso',
    descripcion: 'Visitantes que entraron y accesos de personas de confianza',
    icono: Icons.badge_outlined,
    ruta: '/admin/modulos/control_acceso',
  ),
];

class ResidentDashboardScreen extends StatefulWidget {
  const ResidentDashboardScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<ResidentDashboardScreen> createState() =>
      _ResidentDashboardScreenState();
}

class _ResidentDashboardScreenState extends State<ResidentDashboardScreen> {
  final int _notificacionesCount = 0;

  @override
  void initState() {
    super.initState();
    context.read<FuncionesDashboardBloc>().add(const FuncionesSolicitadas());
  }

  void _abrirModulo(_ModuloResidente modulo) {
    if (modulo.preventivo) {
      context.push(
        modulo.ruta,
        extra: ProximamenteArgs(
          titulo: modulo.titulo,
          descripcion: modulo.descripcion,
        ),
      );
    } else {
      context.push(modulo.ruta);
    }
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
    final funciones = context.watch<FuncionesDashboardBloc>().state.funciones;
    final idsFijos = _modulosResidente.map((modulo) => modulo.id).toSet();
    final funcionesNuevas = funciones
        .where((funcion) => !idsFijos.contains(funcion.id))
        .toList();
    final sections = [
      AppNavSection(
        title: 'Módulos',
        subtitle: 'Todo lo que necesitas de tu comunidad',
        items: [
          ..._modulosResidente.map(
            (modulo) => AppNavItem(
              label: modulo.titulo,
              icon: modulo.icono,
              selected: location == modulo.ruta,
              onTap: () => _abrirModulo(modulo),
            ),
          ),
          ...funcionesNuevas.map(
            (funcion) => AppNavItem(
              label: funcion.titulo,
              icon: iconoDeFuncion(funcion.icono),
              selected: location == funcion.ruta,
              onTap: () => abrirFuncionDashboard(context, funcion),
            ),
          ),
        ],
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
            notificationsCount: _notificacionesCount,
            onNotifications: _notificaciones,
          ),
          body: _ContenidoResidente(usuario: widget.usuario),
        );
      },
    );
  }
}

class _ContenidoResidente extends StatelessWidget {
  const _ContenidoResidente({required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final funciones = context.watch<FuncionesDashboardBloc>().state.funciones;
    final total = _modulosResidente.length + funciones.length;

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
                  _HeroResidente(usuario: usuario),
                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(
                    title: 'Tu comunidad',
                    subtitle: 'Servicios disponibles para ti',
                    trailing: StatusPill(
                      label: '$total módulos',
                      color: context.palette.primary,
                      compact: true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: total,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columnas,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisExtent: 196,
                    ),
                    itemBuilder: (context, index) {
                      if (index >= _modulosResidente.length) {
                        final funcion = funciones[index - _modulosResidente.length];
                        return ModuleCard(
                          title: funcion.titulo,
                          description: funcion.descripcion,
                          icon: iconoDeFuncion(funcion.icono),
                          onTap: () => abrirFuncionDashboard(context, funcion),
                        );
                      }

                      final modulo = _modulosResidente[index];
                      return ModuleCard(
                        title: modulo.titulo,
                        description: modulo.descripcion,
                        icon: modulo.icono,
                        onTap: () {
                          if (modulo.preventivo) {
                            context.push(
                              modulo.ruta,
                              extra: ProximamenteArgs(
                                titulo: modulo.titulo,
                                descripcion: modulo.descripcion,
                              ),
                            );
                          } else {
                            context.push(modulo.ruta);
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Los módulos marcados como próximos se habilitarán en tu recinto.',
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

class _HeroResidente extends StatelessWidget {
  const _HeroResidente({required this.usuario});

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
            right: -20,
            bottom: -34,
            child: Icon(
              Icons.home_work_rounded,
              size: 210,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusPill(
                label: 'RESIDENTE',
                color: p.accent,
                icon: Icons.key_rounded,
                compact: true,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                usuario.rol == Rol.propietario
                    ? 'Panel de propietario'
                    : 'Panel de residente',
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
                  _HeroChip(icon: Icons.inventory_2_rounded, label: 'Paquetería'),
                  _HeroChip(icon: Icons.receipt_long_rounded, label: 'Gastos'),
                  _HeroChip(icon: Icons.security_rounded, label: 'Accesos'),
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
