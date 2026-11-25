import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/usuario.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/asistente/presentation/screens/asistente_admin_screen.dart';
import '../../features/asistente/presentation/screens/asistente_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/modulo_proximamente_screen.dart';
import '../../features/registro_residente/presentation/screens/registro_wizard_screen.dart';
import '../../features/residente/presentation/screens/mi_informacion_screen.dart';
import '../../features/paqueteria/presentation/screens/mis_paquetes_screen.dart';
import '../../features/paqueteria/presentation/screens/paqueteria_gestion_screen.dart';
import '../../features/marketplace/presentation/screens/marketplace_screen.dart';
import '../../features/servicios/presentation/screens/servicios_screen.dart';
import '../../features/infraestructura/presentation/screens/infraestructura_screen.dart';
import '../../features/superadmin/presentation/screens/administradores_screen.dart';
import '../../features/superadmin/presentation/screens/proyectos_screen.dart';
import '../../features/tenant/presentation/bloc/tenant_bloc.dart';
import '../../features/solicitudes_residente/presentation/screens/gestion_residentes_screen.dart';
import '../../features/solicitudes_residente/presentation/screens/solicitud_pendiente_screen.dart';
import '../../features/tenant/presentation/screens/selector_proyecto_screen.dart';
import '../widgets/app_background.dart';
import '../widgets/app_title.dart';
import '../widgets/brand_mark.dart';
import '../theme/app_colors.dart';

class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String registro = '/registro';
  static const String dashboard = '/dashboard';
  static const String residenteMiInformacion = '/residente/mi-informacion';
  static const String residenteAsistente = '/residente/ia';
  static const String adminAsistente = '/admin/modulos/asistente_ia_admin';
  static const String solicitudesResidente =
      '/admin/modulos/solicitudes_residente';
  static const String solicitudPendiente = '/solicitud-pendiente';
  static const String paqueteria = '/paqueteria';
  static const String paqueteriaGestion = '/paqueteria/gestion';
  static const String servicios = '/servicios';
  static const String marketplace = '/marketplace';
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
      final isRegistro = location == AppRoutes.registro;
      final isSelector = location == AppRoutes.selectorProyecto;
      final isAdminRoute = location.startsWith('/admin');
      final isSuperadminRoute = location.startsWith('/superadmin');
      final isResidenteRoute = location.startsWith('/residente');

      switch (authState) {
        case AuthInitial():
        case AuthLoading():
          return isSplash || isRegistro ? null : AppRoutes.splash;
        case AuthSuccess():
          final rol = authState.usuario.rol;
          final rolActivo = rol == Rol.superadmin
              ? rol
              : (tenantState.rolActivo ?? rol);
          if (isSplash || isLogin || isRegistro) return AppRoutes.dashboard;

          final esSolicitudPendiente = location == AppRoutes.solicitudPendiente;

          if (esSolicitudPendiente &&
              rolActivo != Rol.residente &&
              rolActivo != Rol.propietario) {
            return AppRoutes.dashboard;
          }

          final esGestionResidentes =
              location == AppRoutes.solicitudesResidente;
          final esModuloProximamente =
              location.startsWith('/admin/modulos') && !esGestionResidentes;

          if (esGestionResidentes &&
              rolActivo != Rol.administrador &&
              rolActivo != Rol.conserje &&
              rolActivo != Rol.superadmin) {
            return AppRoutes.dashboard;
          }

          if (isAdminRoute &&
              !esModuloProximamente &&
              !esGestionResidentes &&
              rolActivo != Rol.administrador &&
              rolActivo != Rol.superadmin) {
            return AppRoutes.dashboard;
          }

          if (isSuperadminRoute && rolActivo != Rol.superadmin) {
            return AppRoutes.dashboard;
          }

          if (isResidenteRoute &&
              rolActivo != Rol.residente &&
              rolActivo != Rol.propietario) {
            return AppRoutes.dashboard;
          }

          // Enrutamiento multi-tenant para roles con proyecto activo.
          if (rol != Rol.superadmin) {
            if (tenantState.status == TenantStatus.inicial ||
                tenantState.status == TenantStatus.cargando) {
              return AppRoutes.splash;
            }
            if (tenantState.status == TenantStatus.seleccionPendiente) {
              return isSelector ? null : AppRoutes.selectorProyecto;
            }
            if (tenantState.status == TenantStatus.sinProyectos &&
                (rolActivo == Rol.residente || rolActivo == Rol.propietario)) {
              return esSolicitudPendiente ? null : AppRoutes.solicitudPendiente;
            }
            if (tenantState.status == TenantStatus.listo &&
                esSolicitudPendiente) {
              return AppRoutes.dashboard;
            }
            if (isSelector) return AppRoutes.dashboard;
          }

          return null;
        case AuthUnauthenticated():
        case AuthError():
          return (isLogin || isRegistro) ? null : AppRoutes.login;
      }
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const AppTitle(title: 'Cargando', child: _SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const AppTitle(title: 'Ingresar', child: LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.registro,
        builder: (context, state) => const AppTitle(
          title: 'Registro de residente',
          child: RegistroWizardScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) {
          final usuario = state.extra is Usuario
              ? state.extra! as Usuario
              : _usuarioDesdeBloc(context);
          return AppTitle(title: 'Panel', child: DashboardScreen(usuario: usuario));
        },
      ),
      GoRoute(
        path: AppRoutes.selectorProyecto,
        builder: (context, state) => const AppTitle(title: 'Seleccionar recinto', child: SelectorProyectoScreen()),
      ),
      GoRoute(
        path: AppRoutes.superadminInfraestructura,
        builder: (context, state) => const AppTitle(title: 'Infraestructura', child: InfraestructuraScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminAsistente,
        builder: (context, state) => const AppTitle(title: 'Asistente IA', child: AsistenteAdminScreen()),
      ),
      GoRoute(
        path: AppRoutes.solicitudesResidente,
        builder: (context, state) =>
            const AppTitle(title: 'Gestión de residentes', child: GestionResidentesScreen()),
      ),
      GoRoute(
        path: AppRoutes.solicitudPendiente,
        builder: (context, state) =>
            const AppTitle(title: 'Solicitud pendiente', child: SolicitudPendienteScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminModulo('servicios_recomendados'),
        builder: (context, state) => const AppTitle(
          title: 'Servicios recomendados',
          child: ServiciosScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminModulo('marketplace'),
        builder: (context, state) =>
            const AppTitle(title: 'Marketplace', child: MarketplaceScreen()),
      ),
      GoRoute(
        path: '${AppRoutes.adminModulos}/:id',
        builder: (context, state) {
          final args = state.extra is ProximamenteArgs
              ? state.extra! as ProximamenteArgs
              : null;
          return AppTitle(
            title: args?.titulo ?? 'Módulo',
            child: ModuloProximamenteScreen(
              moduloId: state.pathParameters['id'] ?? '',
              titulo: args?.titulo,
              descripcion: args?.descripcion,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.residenteAsistente,
        builder: (context, state) => const AppTitle(title: 'Asistente IA', child: AsistenteScreen()),
      ),
      GoRoute(
        path: AppRoutes.residenteMiInformacion,
        builder: (context, state) {
          final usuario = state.extra is Usuario
              ? state.extra! as Usuario
              : _usuarioDesdeBloc(context);
          return AppTitle(title: 'Mi información', child: MiInformacionScreen(usuario: usuario));
        },
      ),
      GoRoute(
        path: AppRoutes.paqueteria,
        builder: (context, state) {
          final usuario = state.extra is Usuario
              ? state.extra! as Usuario
              : _usuarioDesdeBloc(context);
          return AppTitle(title: 'Paquetería', child: MisPaquetesScreen(usuario: usuario));
        },
      ),
      GoRoute(
        path: AppRoutes.paqueteriaGestion,
        builder: (context, state) {
          final usuario = state.extra is Usuario
              ? state.extra! as Usuario
              : _usuarioDesdeBloc(context);
          return AppTitle(title: 'Gestión de paquetería', child: PaqueteriaGestionScreen(usuario: usuario));
        },
      ),
      GoRoute(
        path: AppRoutes.servicios,
        builder: (context, state) => const AppTitle(
          title: 'Servicios recomendados',
          child: ServiciosScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.marketplace,
        builder: (context, state) =>
            const AppTitle(title: 'Marketplace', child: MarketplaceScreen()),
      ),
      GoRoute(
        path: AppRoutes.superadminProyectos,
        builder: (context, state) => const AppTitle(title: 'Proyectos', child: ProyectosScreen()),
      ),
      GoRoute(
        path: AppRoutes.superadminAdministradores,
        builder: (context, state) => const AppTitle(title: 'Administradores', child: AdministradoresScreen()),
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
    final p = Theme.of(context).brightness == Brightness.dark
        ? darkPalette
        : lightPalette;
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandMark(size: 64, showWordmark: true, subtitle: 'PREMIUM CONDOMINIUM OPS'),
              const SizedBox(height: 28),
              SizedBox(
                width: 160,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: p.border,
                    valueColor: AlwaysStoppedAnimation<Color>(p.accent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
