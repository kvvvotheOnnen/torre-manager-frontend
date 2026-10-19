import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/usuario.dart';
import '../../features/auth/presentation/screens/login_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const String login = '/login';
  static const String adminPanel = '/admin_panel';
  static const String residenteHome = '/residente_home';
  static const String conserjeria = '/conserjeria';

  /// Mapea el rol del usuario a su ruta de inicio (RBAC).
  static String homeForRol(Rol rol) {
    return switch (rol) {
      Rol.administrador => adminPanel,
      Rol.residente => residenteHome,
      Rol.conserje => conserjeria,
    };
  }
}

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminPanel,
        builder: (context, state) => _RolePlaceholder(
          title: 'Panel de Administración',
          usuario: _usuarioFromExtra(state),
        ),
      ),
      GoRoute(
        path: AppRoutes.residenteHome,
        builder: (context, state) => _RolePlaceholder(
          title: 'Inicio Residente',
          usuario: _usuarioFromExtra(state),
        ),
      ),
      GoRoute(
        path: AppRoutes.conserjeria,
        builder: (context, state) => _RolePlaceholder(
          title: 'Conserjería',
          usuario: _usuarioFromExtra(state),
        ),
      ),
    ],
  );
}

Usuario? _usuarioFromExtra(GoRouterState state) {
  final extra = state.extra;
  return extra is Usuario ? extra : null;
}

class _RolePlaceholder extends StatelessWidget {
  const _RolePlaceholder({required this.title, this.usuario});

  final String title;
  final Usuario? usuario;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 64,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                usuario != null
                    ? 'Bienvenido, ${usuario!.nombre}'
                    : 'Bienvenido',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              if (usuario != null)
                Text(
                  'Rol: ${usuario!.rol.name}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 4),
              Text(title, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
