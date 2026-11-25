import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../tenant/presentation/bloc/tenant_bloc.dart';
import 'admin_dashboard_screen.dart';
import 'conserje_dashboard_screen.dart';
import 'resident_dashboard_screen.dart';

/// Descriptor de un módulo visible en el dashboard.
class _Modulo {
  const _Modulo({
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.ruta,
  });

  final String titulo;
  final String descripcion;
  final IconData icono;
  final String ruta;
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.usuario});

  final Usuario usuario;

  /// Define qué módulos ve cada rol. Es el único punto a editar cuando se
  /// agreguen módulos nuevos por perfil.
  List<_Modulo> _modulosPara(Rol rol) {
    const gestionProyectos = _Modulo(
      titulo: 'Gestión de Proyectos',
      descripcion:
          'Crea recintos con su estructura (torres, casas, edificios), '
          'módulos y administradores',
      icono: Icons.apartment,
      ruta: '/superadmin/proyectos',
    );
    const gestionAdministradores = _Modulo(
      titulo: 'Administradores',
      descripcion: 'Crea y lista las cuentas administradoras de recintos',
      icono: Icons.manage_accounts,
      ruta: '/superadmin/administradores',
    );

    return switch (rol) {
      Rol.superadmin => const [gestionProyectos, gestionAdministradores],
      Rol.administrador => const [],
      Rol.residente => const [],
      Rol.conserje => const [],
      Rol.propietario => const [],
    };
  }

  @override
  Widget build(BuildContext context) {
    final rolActivo =
        context.watch<TenantBloc>().state.rolActivo ?? usuario.rol;

    if (rolActivo == Rol.administrador) {
      return AdminDashboardScreen(usuario: usuario);
    }

    if (rolActivo == Rol.residente || rolActivo == Rol.propietario) {
      return ResidentDashboardScreen(usuario: usuario);
    }

    if (rolActivo == Rol.conserje) {
      return ConserjeDashboardScreen(usuario: usuario);
    }

    final modulos = _modulosPara(rolActivo);
    final location = GoRouterState.of(context).matchedLocation;
    final sections = [
      AppNavSection(
        title: 'Administración',
        subtitle: 'Gobierno de la plataforma',
        items: modulos
            .map(
              (modulo) => AppNavItem(
                label: modulo.titulo,
                icon: modulo.icono,
                selected: location == modulo.ruta,
                onTap: () => context.push(modulo.ruta),
              ),
            )
            .toList(),
      ),
    ];

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final esEscritorio = constraints.maxWidth >= 900;
          return AppShell(
            sections: sections,
            userName: usuario.nombre,
            roleLabel: usuario.rol.name,
            onLogout: () =>
                context.read<AuthBloc>().add(const LogoutRequested()),
            topBar: AppTopBar(
              greeting: 'Bienvenido, ${usuario.nombre}',
              avatarName: usuario.nombre,
              roleLabel: usuario.rol.name,
              compact: !esEscritorio,
              showThemeToggle: !esEscritorio,
              onLogout: esEscritorio
                  ? null
                  : () => context.read<AuthBloc>().add(const LogoutRequested()),
            ),
            body: _ContenidoSuperadmin(usuario: usuario, modulos: modulos),
          );
        },
      ),
    );
  }
}

class _ContenidoSuperadmin extends StatelessWidget {
  const _ContenidoSuperadmin({required this.usuario, required this.modulos});

  final Usuario usuario;
  final List<_Modulo> modulos;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;

    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth;
        final columnas = ancho >= 1180
            ? 3
            : ancho >= 760
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
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      gradient: p.hero,
                      borderRadius: AppRadii.xlAll,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      boxShadow: AppShadows.glow(p.primary),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatusPill(
                          label: 'SUPERADMIN',
                          color: p.accent,
                          icon: Icons.workspace_premium_rounded,
                          compact: true,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Gobierno de la plataforma',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Gestiona recintos, su estructura y los administradores '
                          'que operan cada comunidad.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(
                    title: 'Herramientas',
                    subtitle: 'Accesos de superadministración',
                    trailing: StatusPill(
                      label: '${modulos.length} módulos',
                      color: p.primary,
                      compact: true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (modulos.isEmpty)
                    const AppEmptyState(
                      icon: Icons.hourglass_empty_rounded,
                      title: 'Aún no tienes módulos asignados.',
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
                          title: modulo.titulo,
                          description: modulo.descripcion,
                          icon: modulo.icono,
                          onTap: () => context.push(modulo.ruta),
                        );
                      },
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
