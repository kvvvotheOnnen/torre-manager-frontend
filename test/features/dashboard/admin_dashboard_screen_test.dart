import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:torre_manager_frontend/core/errors/failures.dart';
import 'package:torre_manager_frontend/core/tenant/proyecto_activo_store.dart';
import 'package:torre_manager_frontend/features/auth/domain/entities/usuario.dart';
import 'package:torre_manager_frontend/features/dashboard/domain/entities/modulo_dashboard.dart';
import 'package:torre_manager_frontend/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:torre_manager_frontend/features/dashboard/domain/usecases/obtener_modulos_dashboard_usecase.dart';
import 'package:torre_manager_frontend/features/dashboard/presentation/bloc/modulos_dashboard_bloc.dart';
import 'package:torre_manager_frontend/features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/entities/modulo_sistema.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/entities/proyecto_detalle.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/entities/tipo_condominio.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/repositories/superadmin_repository.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/usecases/listar_mis_proyectos_usecase.dart';
import 'package:torre_manager_frontend/features/tenant/presentation/bloc/tenant_bloc.dart';

class _FakeSuperadminRepository implements SuperadminRepositoryInterface {
  @override
  Future<Either<Failure, List<ProyectoDetalle>>> listarMisProyectos() async {
    return const Right([
      ProyectoDetalle(
        id: '1',
        nombre: 'Proyecto Uno',
        descripcion: 'Primero',
        tipoCondominio: TipoCondominio.torres,
        modulos: [ModuloSistema.infraestructura],
        instalacionesExtra: [],
        adminIds: [],
      ),
      ProyectoDetalle(
        id: '2',
        nombre: 'Proyecto Dos',
        descripcion: 'Segundo',
        tipoCondominio: TipoCondominio.casas,
        modulos: [ModuloSistema.paqueteria],
        instalacionesExtra: [],
        adminIds: [],
      ),
    ]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDashboardRepository implements DashboardRepository {
  @override
  Future<Either<Failure, List<ModuloDashboard>>> listarModulos() async {
    return const Right([
      ModuloDashboard(
        id: 'infraestructura',
        nombre: 'Infraestructura',
        descripcion: 'Estructura del recinto',
        tipo: TipoModuloDashboard.proyecto,
        habilitado: true,
      ),
      ModuloDashboard(
        id: 'paqueteria',
        nombre: 'Paquetería',
        descripcion: 'Encomiendas',
        tipo: TipoModuloDashboard.proyecto,
        habilitado: false,
      ),
      ModuloDashboard(
        id: 'registro_conserjes',
        nombre: 'Registro de conserjes',
        descripcion: 'Gestión de conserjes',
        tipo: TipoModuloDashboard.general,
        habilitado: true,
      ),
    ]);
  }
}

class _MemoriaProyectoActivoStore implements ProyectoActivoStore {
  String? _proyectoId;

  @override
  Future<void> clear() async {
    _proyectoId = null;
  }

  @override
  Future<String?> readProyectoId() async => _proyectoId;

  @override
  Future<void> saveProyectoId(String proyectoId) async {
    _proyectoId = proyectoId;
  }
}

const _usuario = Usuario(
  id: '1',
  nombre: 'Admin Demo',
  correo: 'admin@example.test',
  rol: Rol.administrador,
);

Future<({TenantBloc tenantBloc, ModulosDashboardBloc modulosBloc})>
_crearBlocs() async {
  final tenantBloc = TenantBloc(
    listarMisProyectosUseCase: ListarMisProyectosUseCase(
      _FakeSuperadminRepository(),
    ),
    proyectoActivoStore: _MemoriaProyectoActivoStore(),
  );
  final modulosBloc = ModulosDashboardBloc(
    obtenerModulosUseCase: ObtenerModulosDashboardUseCase(
      _FakeDashboardRepository(),
    ),
  );

  final resolucion = tenantBloc.stream.firstWhere(
    (state) => state.status == TenantStatus.seleccionPendiente,
  );
  tenantBloc.add(const TenantResuelto());
  await resolucion;

  final seleccion = tenantBloc.stream.firstWhere(
    (state) => state.status == TenantStatus.listo,
  );
  tenantBloc.add(const TenantProyectoSeleccionado('1'));
  await seleccion;

  return (tenantBloc: tenantBloc, modulosBloc: modulosBloc);
}

Widget _app(TenantBloc tenantBloc, ModulosDashboardBloc modulosBloc) {
  final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(
        path: '/dashboard',
        builder: (context, state) =>
            const AdminDashboardScreen(usuario: _usuario),
      ),
    ],
  );

  return MultiBlocProvider(
    providers: [
      BlocProvider<TenantBloc>.value(value: tenantBloc),
      BlocProvider<ModulosDashboardBloc>.value(value: modulosBloc),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('desktop muestra sidebar, usuario, selector y módulos', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final blocs = await _crearBlocs();
    addTearDown(blocs.tenantBloc.close);
    addTearDown(blocs.modulosBloc.close);

    await tester.pumpWidget(_app(blocs.tenantBloc, blocs.modulosBloc));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Bienvenido, Admin Demo'), findsOneWidget);
    expect(find.text('MÓDULOS DEL PROYECTO'), findsOneWidget);
    expect(find.text('MÓDULOS GENERALES'), findsOneWidget);
    expect(find.text('Infraestructura'), findsWidgets);
    expect(find.text('Paquetería'), findsWidgets);
    expect(find.text('No habilitado para este proyecto.'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsWidgets);
  });

  testWidgets('móvil usa drawer para acceder a los módulos', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final blocs = await _crearBlocs();
    addTearDown(blocs.tenantBloc.close);
    addTearDown(blocs.modulosBloc.close);

    await tester.pumpWidget(_app(blocs.tenantBloc, blocs.modulosBloc));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('MÓDULOS DEL PROYECTO'), findsNothing);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('MÓDULOS DEL PROYECTO'), findsOneWidget);
    expect(find.text('MÓDULOS GENERALES'), findsOneWidget);
  });
}
