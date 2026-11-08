import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:torre_manager_frontend/core/errors/failures.dart';
import 'package:torre_manager_frontend/features/dashboard/domain/entities/modulo_dashboard.dart';
import 'package:torre_manager_frontend/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:torre_manager_frontend/features/dashboard/domain/usecases/obtener_modulos_dashboard_usecase.dart';
import 'package:torre_manager_frontend/features/dashboard/presentation/bloc/modulos_dashboard_bloc.dart';

class _FakeDashboardRepository implements DashboardRepository {
  _FakeDashboardRepository(this.result);

  final Either<Failure, List<ModuloDashboard>> result;
  int llamadas = 0;

  @override
  Future<Either<Failure, List<ModuloDashboard>>> listarModulos() async {
    llamadas++;
    return result;
  }
}

void main() {
  const modulos = [
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
      tipo: TipoModuloDashboard.general,
      habilitado: true,
    ),
    ModuloDashboard(
      id: 'registro_conserjes',
      nombre: 'Registro de conserjes',
      descripcion: 'Gestión de conserjes',
      tipo: TipoModuloDashboard.general,
      habilitado: true,
    ),
  ];

  test('emite cargando y cargado con los módulos del backend', () async {
    final repositorio = _FakeDashboardRepository(const Right(modulos));
    final bloc = ModulosDashboardBloc(
      obtenerModulosUseCase: ObtenerModulosDashboardUseCase(repositorio),
    );

    final states = <ModulosDashboardState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(const ModulosDashboardSolicitados());
    await pumpEventQueue();
    await subscription.cancel();
    await bloc.close();

    expect(states.first.status, ModulosDashboardStatus.cargando);
    expect(states.last.status, ModulosDashboardStatus.cargado);
    expect(states.last.modulos, [modulos[1], modulos[2]]);
    expect(states.last.modulosProyecto, isEmpty);
    expect(states.last.modulosGenerales, [modulos[1], modulos[2]]);
    expect(
      states.last.modulos.any((modulo) => modulo.id == 'infraestructura'),
      isFalse,
    );
    expect(repositorio.llamadas, 1);
  });

  test('emite error conservando los módulos previos', () async {
    final repositorio = _FakeDashboardRepository(
      const Left(ServerFailure('No fue posible cargar')),
    );
    final bloc = ModulosDashboardBloc(
      obtenerModulosUseCase: ObtenerModulosDashboardUseCase(repositorio),
    );

    final states = <ModulosDashboardState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(const ModulosDashboardSolicitados());
    await pumpEventQueue();
    await subscription.cancel();
    await bloc.close();

    expect(states.last.status, ModulosDashboardStatus.error);
    expect(states.last.mensaje, 'No fue posible cargar');
    expect(states.last.modulos, isEmpty);
  });
}
