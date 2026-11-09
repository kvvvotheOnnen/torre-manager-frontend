import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/usuario.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/modulo_proximamente_screen.dart';
import '../../features/residente/presentation/screens/mi_informacion_screen.dart';
import '../../features/infraestructura/presentation/screens/infraestructura_screen.dart';
import '../../features/superadmin/presentation/screens/administradores_screen.dart';
import '../../features/superadmin/presentation/screens/proyectos_screen.dart';
import '../../features/tenant/presentation/bloc/tenant_bloc.dart';
import '../../features/tenant/presentation/screens/selector_proyecto_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String residenteMiInformacion = '/residente/mi-informacion';
  static const String selectorProyecto = '/selector-proyecto';
  static const String superadminInfraestructura = '/superadmin/infraestructura';
  static const String adminModulos = '/admin/modulos';
  static String adminModulo(String id) =>
      '$adminModulos/${Uri.encodeComponent(id)}';
  static const String superadminProyectos = '/superadmin/proyectos';
  static const String superadminAdministradores = '/superadmin/administradores';

  /// Todos los roles llegan al mismo dashboard; los módulos varían por rol.
  static String homeForRol(Rol rol) => dashboard;
}

GoRouter buildRouter(AuthBloc authBloc, TenantBloc tenantBloc) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _AuthStateListenable(authBloc, tenantBloc),
    redirect: (context, state) {
      final authState = authBloc.state;
      final tenantState = tenantBloc.state;
      final location = state.matchedLocation;

      final isSplash = location == AppRoutes.splash;
      final isLogin = location == AppRoutes.login;
      final isSelector = location == AppRoutes.selectorProyecto;
      final isAdminRoute = location.startsWith('/admin');
      final isSuperadminRoute = location.startsWith('/superadmin');

      switch (authState) {
        case AuthInitial():
        case AuthLoading():
          return isSplash ? null : AppRoutes.splash;
        case AuthSuccess():
          final rol = authState.usuario.rol;
          if (isSplash || isLogin) return AppRoutes.dashboard;

          final esModuloProximamente = location.startsWith('/admin/modulos');
          if (isAdminRoute &&
              !esModuloProximamente &&
              rol != Rol.administrador &&
              rol != Rol.superadmin) {
            return AppRoutes.dashboard;
          }

          if (isSuperadminRoute && rol != Rol.superadmin) {
            return AppRoutes.dashboard;
          }

          // Enrutamiento multi-tenant del administrador.
          if (rol == Rol.administrador) {
            if (tenantState.status == TenantStatus.cargando) {
              return AppRoutes.splash;
            }
            if (tenantState.status == TenantStatus.seleccionPendiente) {
              return isSelector ? null : AppRoutes.selectorProyecto;
            }
            if (isSelector) return AppRoutes.dashboard;
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
        path: AppRoutes.selectorProyecto,
        builder: (context, state) => const SelectorProyectoScreen(),
      ),
      GoRoute(
        path: AppRoutes.superadminInfraestructura,
        builder: (context, state) => const InfraestructuraScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.adminModulos}/:id',
        builder: (context, state) {
          final args = state.extra is ProximamenteArgs
              ? state.extra! as ProximamenteArgs
              : null;
          return ModuloProximamenteScreen(
            moduloId: state.pathParameters['id'] ?? '',
            titulo: args?.titulo,
            descripcion: args?.descripcion,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.residenteMiInformacion,
        builder: (context, state) {
          final usuario = state.extra is Usuario
              ? state.extra! as Usuario
              : _usuarioDesdeBloc(context);
          return MiInformacionScreen(usuario: usuario);
        },
      ),
      GoRoute(
        path: AppRoutes.superadminProyectos,
        builder: (context, state) => const ProyectosScreen(),
      ),
      GoRoute(
        path: AppRoutes.superadminAdministradores,
        builder: (context, state) => const AdministradoresScreen(),
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

/// Adaptador que expone los streams del [AuthBloc] y del [TenantBloc] como
/// [Listenable] para que go_router reevalúe los redirects.
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(AuthBloc authBloc, TenantBloc tenantBloc) {
    authBloc.stream.listen((_) => notifyListeners());
    tenantBloc.stream.listen((_) => notifyListeners());
  }
}
