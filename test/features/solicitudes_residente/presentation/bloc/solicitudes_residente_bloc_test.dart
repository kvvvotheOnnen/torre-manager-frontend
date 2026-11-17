import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:torre_manager_frontend/core/errors/failures.dart';
import 'package:torre_manager_frontend/features/solicitudes_residente/domain/entities/solicitud_residente.dart';
import 'package:torre_manager_frontend/features/solicitudes_residente/domain/repositories/solicitudes_residente_repository.dart';
import 'package:torre_manager_frontend/features/solicitudes_residente/domain/usecases/aprobar_solicitud_usecase.dart';
import 'package:torre_manager_frontend/features/solicitudes_residente/domain/usecases/listar_historial_usecase.dart';
import 'package:torre_manager_frontend/features/solicitudes_residente/domain/usecases/listar_pendientes_usecase.dart';
import 'package:torre_manager_frontend/features/solicitudes_residente/domain/usecases/rechazar_solicitud_usecase.dart';
import 'package:torre_manager_frontend/features/solicitudes_residente/presentation/bloc/solicitudes_residente_bloc.dart';

const _pendiente = SolicitudResidente(
  id: '1',
  proyectoId: '1',
  unidadPrincipalId: '9',
  unidad: 'Edificio-803',
  agrupacion: 'Edificio',
  tipoSolicitud: TipoSolicitud.propietario,
  origen: OrigenSolicitud.seeder,
  estado: EstadoSolicitud.pendiente,
  personas: [],
  instalaciones: [],
  createdAt: '2026-11-16 10:00:00',
);

const _historica = SolicitudResidente(
  id: '2',
  proyectoId: '1',
  unidadPrincipalId: '10',
  unidad: 'Edificio-804',
  agrupacion: 'Edificio',
  tipoSolicitud: TipoSolicitud.arrendatario,
  origen: OrigenSolicitud.seeder,
  estado: EstadoSolicitud.aprobada,
  personas: [],
  instalaciones: [],
  createdAt: '2026-11-16 09:00:00',
  decididoAt: '2026-11-16 11:00:00',
);

class _FakeRepository implements SolicitudesResidenteRepository {
  List<SolicitudResidente> pendientes = [_pendiente];
  List<SolicitudResidente> historial = [_historica];
  String? rechazoMotivo;

  @override
  Future<Either<Failure, List<SolicitudResidente>>> listarPendientes() async =>
      Right(pendientes);

  @override
  Future<Either<Failure, List<SolicitudResidente>>> listarHistorial() async =>
      Right(historial);

  @override
  Future<Either<Failure, SolicitudResidente>> aprobar(String id) async {
    pendientes = pendientes.where((s) => s.id != id).toList();
    return const Right(_historica);
  }

  @override
  Future<Either<Failure, SolicitudResidente>> rechazar(
    String id,
    String motivo,
  ) async {
    rechazoMotivo = motivo;
    pendientes = pendientes.where((s) => s.id != id).toList();
    return const Right(_historica);
  }
}

SolicitudesResidenteBloc _bloc(_FakeRepository repository) {
  return SolicitudesResidenteBloc(
    ListarSolicitudesPendientesUseCase(repository),
    ListarHistorialSolicitudesUseCase(repository),
    AprobarSolicitudUseCase(repository),
    RechazarSolicitudUseCase(repository),
  );
}

void main() {
  test('carga pendientes al iniciar', () async {
    final bloc = _bloc(_FakeRepository());
    final esperado = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<SolicitudesResidenteState>().having(
          (s) => s.status,
          'status',
          SolicitudesResidenteStatus.cargando,
        ),
        isA<SolicitudesResidenteState>()
            .having(
              (s) => s.status,
              'status',
              SolicitudesResidenteStatus.cargado,
            )
            .having((s) => s.pendientes.length, 'pendientes', 1),
      ]),
    );

    bloc.add(const SolicitudesResidenteIniciadas());
    await esperado;
    await bloc.close();
  });

  test('aprueba y recarga historial', () async {
    final repository = _FakeRepository();
    final bloc = _bloc(repository);

    bloc.add(const SolicitudAprobada('1'));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.pendientes, isEmpty);
    expect(bloc.state.mensaje, contains('aprobada'));
    await bloc.close();
  });

  test('rechaza con motivo', () async {
    final repository = _FakeRepository();
    final bloc = _bloc(repository);

    bloc.add(const SolicitudRechazada('1', 'Datos incompletos'));
    await Future<void>.delayed(Duration.zero);

    expect(repository.rechazoMotivo, 'Datos incompletos');
    expect(bloc.state.pendientes, isEmpty);
    await bloc.close();
  });
}
