import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:torre_manager_frontend/core/errors/failures.dart';
import 'package:torre_manager_frontend/features/dashboard/domain/entities/funcion_dashboard.dart';
import 'package:torre_manager_frontend/features/dashboard/domain/repositories/funciones_dashboard_repository.dart';
import 'package:torre_manager_frontend/features/dashboard/domain/usecases/obtener_funciones_dashboard_usecase.dart';
import 'package:torre_manager_frontend/features/dashboard/presentation/bloc/funciones_dashboard_bloc.dart';

class _RepositorioFalso implements FuncionesDashboardRepository {
  _RepositorioFalso(this._resultado);

  final Either<Failure, List<FuncionDashboard>> _resultado;
  int llamadas = 0;

  @override
  Future<Either<Failure, List<FuncionDashboard>>> listarFunciones() async {
    llamadas++;

    return _resultado;
  }
}

const _funcion = FuncionDashboard(
  id: 'avisos',
  titulo: 'Avisos',
  descripcion: 'Noticias del proyecto',
  icono: 'campaign',
  capacidades: ['alertas.leer'],
  ambito: AmbitoFuncion.proyecto,
  ruta: '/avisos',
);

void main() {
  test('emite cargando y luego las funciones recibidas', () async {
    final repositorio = _RepositorioFalso(const Right([_funcion]));
    final bloc = FuncionesDashboardBloc(
      obtenerFunciones: ObtenerFuncionesDashboardUseCase(repositorio),
    );
    final estados = <FuncionesDashboardState>[];
    final suscripcion = bloc.stream.listen(estados.add);

    bloc.add(const FuncionesSolicitadas());
    await pumpEventQueue();

    expect(estados.first.status, FuncionesDashboardStatus.cargando);
    expect(estados.last.status, FuncionesDashboardStatus.cargado);
    expect(estados.last.funciones, [_funcion]);
    expect(estados.last.tieneFunciones, isTrue);

    await suscripcion.cancel();
    await bloc.close();
  });

  test('emite error con el mensaje del fallo y conserva la lista', () async {
    final repositorio = _RepositorioFalso(
      const Left(ServerFailure('Proyecto no encontrado.')),
    );
    final bloc = FuncionesDashboardBloc(
      obtenerFunciones: ObtenerFuncionesDashboardUseCase(repositorio),
    );
    final estados = <FuncionesDashboardState>[];
    final suscripcion = bloc.stream.listen(estados.add);

    bloc.add(const FuncionesRefrescadas());
    await pumpEventQueue();

    expect(estados.last.status, FuncionesDashboardStatus.error);
    expect(estados.last.mensaje, 'Proyecto no encontrado.');
    expect(estados.last.tieneError, isTrue);
    expect(repositorio.llamadas, 1);

    await suscripcion.cancel();
    await bloc.close();
  });
}
