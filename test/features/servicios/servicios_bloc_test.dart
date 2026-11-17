import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:torre_manager_frontend/core/errors/failures.dart';
import 'package:torre_manager_frontend/features/servicios/domain/entities/tipo_servicio.dart';
import 'package:torre_manager_frontend/features/servicios/domain/entities/trabajador_servicio.dart';
import 'package:torre_manager_frontend/features/servicios/domain/entities/trabajador_servicio_foto.dart';
import 'package:torre_manager_frontend/features/servicios/domain/repositories/servicios_repository.dart';
import 'package:torre_manager_frontend/features/servicios/domain/usecases/actualizar_trabajador_usecase.dart';
import 'package:torre_manager_frontend/features/servicios/domain/usecases/crear_trabajador_usecase.dart';
import 'package:torre_manager_frontend/features/servicios/domain/usecases/eliminar_trabajador_usecase.dart';
import 'package:torre_manager_frontend/features/servicios/domain/usecases/listar_trabajadores_usecase.dart';
import 'package:torre_manager_frontend/features/servicios/presentation/bloc/servicios_bloc.dart';

const _electricista = TrabajadorServicio(
  id: '1',
  nombre: 'Andrés',
  nombreEmpresa: null,
  telefono: '123',
  tipo: TipoServicio.electricista,
  descripcion: null,
  fotoUrl: null,
);

const _gasfiter = TrabajadorServicio(
  id: '2',
  nombre: 'Luis',
  nombreEmpresa: 'Gasfitería Fuentes',
  telefono: '456',
  tipo: TipoServicio.gasfiter,
  descripcion: 'Filtraciones y destapes',
  fotoUrl: null,
);

class _FakeServiciosRepository implements ServiciosRepositoryInterface {
  List<TrabajadorServicio> trabajadores = const [_electricista];
  TipoServicio? ultimoTipo;
  String? ultimaBusqueda;
  String? idEliminado;
  bool fallaListado = false;
  int listados = 0;

  @override
  Future<Either<Failure, List<TrabajadorServicio>>> listar({
    TipoServicio? tipo,
    String? buscar,
  }) async {
    listados++;
    ultimoTipo = tipo;
    ultimaBusqueda = buscar;
    if (fallaListado) {
      return const Left(ServerFailure('Sin conexión.'));
    }
    return Right(trabajadores);
  }

  @override
  Future<Either<Failure, TrabajadorServicio>> crear({
    required String nombre,
    String? nombreEmpresa,
    required String telefono,
    required TipoServicio tipo,
    String? descripcion,
    TrabajadorServicioFoto? foto,
  }) async {
    trabajadores = [
      ...trabajadores,
      TrabajadorServicio(
        id: '${trabajadores.length + 1}',
        nombre: nombre,
        nombreEmpresa: nombreEmpresa,
        telefono: telefono,
        tipo: tipo,
        descripcion: descripcion,
        fotoUrl: foto == null ? null : 'http://foto',
      ),
    ];
    return Right(trabajadores.last);
  }

  @override
  Future<Either<Failure, TrabajadorServicio>> actualizar({
    required String id,
    required String nombre,
    String? nombreEmpresa,
    required String telefono,
    required TipoServicio tipo,
    String? descripcion,
    TrabajadorServicioFoto? foto,
  }) async {
    final actualizado = TrabajadorServicio(
      id: id,
      nombre: nombre,
      nombreEmpresa: nombreEmpresa,
      telefono: telefono,
      tipo: tipo,
      descripcion: descripcion,
      fotoUrl: foto == null ? null : 'http://foto',
    );
    trabajadores = [
      for (final trabajador in trabajadores)
        if (trabajador.id == id) actualizado else trabajador,
    ];
    return Right(actualizado);
  }

  @override
  Future<Either<Failure, bool>> eliminar(String id) async {
    idEliminado = id;
    trabajadores = trabajadores
        .where((trabajador) => trabajador.id != id)
        .toList();
    return const Right(true);
  }
}

ServiciosBloc _crearBloc(_FakeServiciosRepository repository) {
  return ServiciosBloc(
    listar: ListarTrabajadoresUseCase(repository),
    crear: CrearTrabajadorUseCase(repository),
    actualizar: ActualizarTrabajadorUseCase(repository),
    eliminar: EliminarTrabajadorUseCase(repository),
  );
}

void main() {
  late _FakeServiciosRepository repository;
  late ServiciosBloc bloc;
  late List<ServiciosState> estados;

  setUp(() {
    repository = _FakeServiciosRepository();
    bloc = _crearBloc(repository);
    estados = [];
    bloc.stream.listen(estados.add);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('carga los trabajadores del proyecto', () async {
    bloc.add(const ServiciosSolicitados());
    await pumpEventQueue();

    expect(estados.first.cargando, isTrue);
    expect(estados.last.status, ServiciosStatus.cargado);
    expect(estados.last.trabajadores, const [_electricista]);
  });

  test('conserva el mensaje de error del repositorio', () async {
    repository.fallaListado = true;
    bloc.add(const ServiciosSolicitados());
    await pumpEventQueue();

    expect(estados.last.status, ServiciosStatus.error);
    expect(estados.last.mensaje, 'Sin conexión.');
  });

  test('filtra por tipo en memoria sin volver a consultar', () async {
    repository.trabajadores = const [_electricista, _gasfiter];
    bloc.add(const ServiciosSolicitados());
    await pumpEventQueue();
    final listadosIniciales = repository.listados;

    bloc.add(const FiltroServicioCambiado(TipoServicio.gasfiter));
    await pumpEventQueue();

    expect(repository.listados, listadosIniciales);
    expect(estados.last.tipo, TipoServicio.gasfiter);
    expect(estados.last.trabajadoresVisibles, const [_gasfiter]);
  });

  test('busca por tipo y sin distinguir mayúsculas ni tildes', () async {
    repository.trabajadores = const [_electricista, _gasfiter];
    bloc.add(const ServiciosSolicitados());
    await pumpEventQueue();

    bloc.add(const BusquedaServiciosCambiada('ELECTRICISTA'));
    await pumpEventQueue();
    expect(estados.last.trabajadoresVisibles, const [_electricista]);

    bloc.add(const BusquedaServiciosCambiada('andres'));
    await pumpEventQueue();
    expect(estados.last.trabajadoresVisibles, const [_electricista]);

    bloc.add(const BusquedaServiciosCambiada('gasfiteria'));
    await pumpEventQueue();
    expect(estados.last.trabajadoresVisibles, const [_gasfiter]);

    expect(repository.listados, 1);
  });

  test('agrega un trabajador y recarga la lista', () async {
    bloc.add(
      const TrabajadorGuardado(
        nombre: 'Pedro',
        telefono: '555',
        tipo: TipoServicio.maestro,
      ),
    );
    await pumpEventQueue();

    expect(repository.trabajadores, hasLength(2));
    expect(estados.last.mensaje, 'Trabajador agregado.');
    expect(estados.last.guardando, isFalse);
    expect(repository.listados, 1);
  });

  test('elimina y recarga la lista', () async {
    bloc.add(const TrabajadorEliminadoSolicitado('1'));
    await pumpEventQueue();

    expect(repository.idEliminado, '1');
    expect(estados.last.mensaje, 'Trabajador eliminado.');
    expect(repository.listados, 1);
  });
}
