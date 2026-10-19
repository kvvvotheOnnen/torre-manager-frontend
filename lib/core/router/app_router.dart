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
        builder: (context, state) =>
            const _RolePlaceholder(title: 'Panel de Administración'),
      ),
      GoRoute(
        path: AppRoutes.residenteHome,
        builder: (context, state) =>
            const _RolePlaceholder(title: 'Inicio Residente'),
      ),
      GoRoute(
        path: AppRoutes.conserjeria,
        builder: (context, state) =>
            const _RolePlaceholder(title: 'Conserjería'),
      ),
    ],
  );
}

class _RolePlaceholder extends StatelessWidget {
  const _RolePlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
