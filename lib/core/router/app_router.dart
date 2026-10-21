import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/usuario.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/infraestructura/presentation/screens/infraestructura_screen.dart';
import '../../features/superadmin/presentation/screens/proyectos_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String adminInfraestructura = '/admin/infraestructura';
  static const String superadminProyectos = '/superadmin/proyectos';

  /// Todos los roles llegan al mismo dashboard; los módulos varían por rol.
  static String homeForRol(Rol rol) => dashboard;
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
      final isInfraestructura = location == AppRoutes.adminInfraestructura;
      final isSuperadminRoute = location.startsWith('/superadmin');

      switch (authState) {
        case AuthInitial():
        case AuthLoading():
          return isSplash ? null : AppRoutes.splash;
        case AuthSuccess():
          final rol = authState.usuario.rol;
          if (isSplash || isLogin) return AppRoutes.dashboard;

          // RBAC: Infraestructura administrador + superadmin (herencia).
          if (isInfraestructura &&
              rol != Rol.administrador &&
              rol != Rol.superadmin) {
            return AppRoutes.dashboard;
          }

          // RBAC: rutas de plataforma exclusivas del superadmin.
          if (isSuperadminRoute && rol != Rol.superadmin) {
            return AppRoutes.dashboard;
          }

          return null;
        case AuthUnauthenticated():
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
        path: AppRoutes.dashboard,
        builder: (context, state) {
          final usuario = state.extra is Usuario
              ? state.extra! as Usuario
              : _usuarioDesdeBloc(context);
          return DashboardScreen(usuario: usuario);
        },
      ),
      GoRoute(
        path: AppRoutes.adminInfraestructura,
        builder: (context, state) => const InfraestructuraScreen(),
      ),
      GoRoute(
        path: AppRoutes.superadminProyectos,
        builder: (context, state) => const ProyectosScreen(),
      ),
    ],
  );
}

Usuario _usuarioDesdeBloc(BuildContext context) {
  final state = context.read<AuthBloc>().state;
  if (state is AuthSuccess) return state.usuario;
  throw StateError('Usuario no autenticado.');
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/// Adaptador que expone el stream del [AuthBloc] como [Listenable]
/// para que go_router reevalúe los redirects ante cambios de sesión.
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(AuthBloc bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}
