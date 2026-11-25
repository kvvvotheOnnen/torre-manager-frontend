import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:torre_manager_frontend/core/errors/failures.dart';
import 'package:torre_manager_frontend/features/registro_residente/domain/entities/registro_residente.dart';
import 'package:torre_manager_frontend/features/registro_residente/domain/repositories/registro_residente_repository.dart';
import 'package:torre_manager_frontend/features/registro_residente/domain/usecases/listar_proyectos_registro_usecase.dart';
import 'package:torre_manager_frontend/features/registro_residente/domain/usecases/listar_unidades_registro_usecase.dart';
import 'package:torre_manager_frontend/features/registro_residente/domain/usecases/registrar_solicitud_residente_usecase.dart';
import 'package:torre_manager_frontend/features/registro_residente/presentation/bloc/registro_residente_bloc.dart';

const _proyecto = ProyectoRegistro(id: '1', nombre: 'Condominio Demo');
const _unidad = UnidadRegistro(
  id: '9',
  identificador: '101',
  agrupacion: 'Torre A',
  etiqueta: 'Torre A - 101',
);

class _FakeRepository implements RegistroResidenteRepository {
  _FakeRepository({this.fallaRegistro = false, this.fallaUnidades = false});

  final bool fallaRegistro;
  final bool fallaUnidades;

  @override
  Future<Either<Failure, List<ProyectoRegistro>>> listarProyectos() async =>
      const Right([_proyecto]);

  @override
  Future<Either<Failure, List<UnidadRegistro>>> listarUnidades(
    String proyectoId,
  ) async => fallaUnidades
      ? const Left(ServerFailure('No fue posible cargar las unidades.'))
      : const Right([_unidad]);

  @override
  Future<Either<Failure, String>> registrar(
    SolicitudRegistro solicitud,
  ) async => fallaRegistro
      ? const Left(ServerFailure('El correo ya está registrado.'))
      : const Right('Solicitud registrada.');
}

RegistroResidenteBloc _crearBloc(RegistroResidenteRepository repository) {
  return RegistroResidenteBloc(
    listarProyectosUseCase: ListarProyectosRegistroUseCase(repository),
    listarUnidadesUseCase: ListarUnidadesRegistroUseCase(repository),
    registrarUseCase: RegistrarSolicitudResidenteUseCase(repository),
  );
}

const _solicitud = SolicitudRegistro(
  proyectoId: '1',
  unidadPrincipalId: '9',
  tipoVinculo: TipoVinculoRegistro.propietario,
  password: 'password123',
  personas: [
    PersonaRegistro(
      nombre: 'Principal Demo',
      rut: '12345678-5',
      email: 'principal@example.test',
      telefono: '+56911111111',
      telefonoEmergencia: '+56922222222',
      nombreEmergencia: 'Contacto',
    ),
  ],
  mascotas: [],
);

void main() {
  test('carga proyectos y unidades', () async {
    final bloc = _crearBloc(_FakeRepository());

    final esperadoProyectos = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<RegistroResidenteState>().having(
          (s) => s.cargandoProyectos,
          'cargando',
          true,
        ),
        isA<RegistroResidenteState>()
            .having((s) => s.cargandoProyectos, 'cargando', false)
            .having((s) => s.proyectos, 'proyectos', [_proyecto]),
      ]),
    );

    bloc.add(const RegistroProyectosSolicitados());
    await esperadoProyectos;

    final esperadoUnidades = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<RegistroResidenteState>().having(
          (s) => s.cargandoUnidades,
          'cargando',
          true,
        ),
        isA<RegistroResidenteState>()
            .having((s) => s.cargandoUnidades, 'cargando', false)
            .having((s) => s.unidades, 'unidades', [_unidad]),
      ]),
    );

    bloc.add(const RegistroUnidadesSolicitadas('1'));
    await esperadoUnidades;
    await bloc.close();
  });

  test('expone error de unidades distinto de una lista vacía', () async {
    final bloc = _crearBloc(_FakeRepository(fallaUnidades: true));

    final esperado = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<RegistroResidenteState>().having(
          (s) => s.cargandoUnidades,
          'cargando',
          true,
        ),
        isA<RegistroResidenteState>()
            .having((s) => s.cargandoUnidades, 'cargando', false)
            .having((s) => s.unidades, 'unidades', isEmpty)
            .having(
              (s) => s.errorUnidades,
              'errorUnidades',
              'No fue posible cargar las unidades.',
            ),
      ]),
    );

    bloc.add(const RegistroUnidadesSolicitadas('1'));
    await esperado;
    await bloc.close();
  });

  test('registra la solicitud y marca enviado', () async {
    final bloc = _crearBloc(_FakeRepository());

    final esperado = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<RegistroResidenteState>().having((s) => s.enviando, 'enviando', true),
        isA<RegistroResidenteState>()
            .having((s) => s.enviando, 'enviando', false)
            .having((s) => s.enviado, 'enviado', true)
            .having((s) => s.mensajeExito, 'mensaje', 'Solicitud registrada.'),
      ]),
    );

    bloc.add(const RegistroSolicitudEnviada(_solicitud));
    await esperado;
    await bloc.close();
  });

  test('expone el error del backend al registrar', () async {
    final bloc = _crearBloc(_FakeRepository(fallaRegistro: true));

    final esperado = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<RegistroResidenteState>().having((s) => s.enviando, 'enviando', true),
        isA<RegistroResidenteState>()
            .having((s) => s.enviando, 'enviando', false)
            .having((s) => s.enviado, 'enviado', false)
            .having(
              (s) => s.error,
              'error',
              'El correo ya está registrado.',
            ),
      ]),
    );

    bloc.add(const RegistroSolicitudEnviada(_solicitud));
    await esperado;
    await bloc.close();
  });
}
