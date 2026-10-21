import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/screens/admin_panel_screen.dart';
import '../../features/auth/domain/entities/usuario.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/infraestructura/presentation/screens/infraestructura_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String adminPanel = '/admin_panel';
  static const String adminInfraestructura = '/admin/infraestructura';
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

GoRouter buildRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _AuthStateListenable(authBloc),
    redirect: (context, state) {
      final authState = authBloc.state;
      final location = state.matchedLocation;

      final isSplash = location == AppRoutes.splash;
      final isLogin = location == AppRoutes.login;
      final isAdminRoute = location == AppRoutes.adminPanel ||
          location.startsWith('/admin');

      switch (authState) {
        case AuthInitial():
          // La sesión aún no fue verificada: solo se permite el splash.
          return isSplash ? null : AppRoutes.splash;
        case AuthLoading():
          return isSplash ? null : AppRoutes.splash;
        case AuthSuccess():
          final usuario = authState.usuario;
          if (isSplash || isLogin) {
            return AppRoutes.homeForRol(usuario.rol);
          }
          // RBAC: las rutas /admin/* son exclusivas del Administrador.
          if (isAdminRoute && usuario.rol != Rol.administrador) {
            return AppRoutes.homeForRol(usuario.rol);
          }
          return null;
        case AuthUnauthenticated():
          return isLogin ? null : AppRoutes.login;
        case AuthError():
          return isLogin ? null : AppRoutes.login;
      }
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminPanel,
        builder: (context, state) {
          final usuario = state.extra is Usuario
              ? state.extra! as Usuario
              : _usuarioDesdeBloc(context);
          return AdminPanelScreen(usuario: usuario);
        },
      ),
      GoRoute(
        path: AppRoutes.adminInfraestructura,
        builder: (context, state) => const InfraestructuraScreen(),
      ),
      GoRoute(
        path: AppRoutes.residenteHome,
        builder: (context, state) => const _RolePlaceholder(
          title: 'Inicio Residente',
        ),
      ),
      GoRoute(
        path: AppRoutes.conserjeria,
        builder: (context, state) => const _RolePlaceholder(
          title: 'Conserjería',
        ),
      ),
    ],
  );
}

Usuario _usuarioDesdeBloc(BuildContext context) {
  final state = context.read<AuthBloc>().state;
  if (state is AuthSuccess) return state.usuario;
  throw StateError('Usuario no autenticado.');
}

/// Adaptador que expone el stream del [AuthBloc] como [Listenable]
/// para que go_router reevalúe los redirects ante cambios de sesión.
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(AuthBloc bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _RolePlaceholder extends StatelessWidget {
  const _RolePlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    final usuario = state is AuthSuccess ? state.usuario : null;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              usuario != null ? 'Bienvenido, ${usuario.nombre}' : 'Bienvenido',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (usuario != null) Text('Rol: ${usuario.rol.name}'),
          ],
        ),
      ),
    );
  }
}
