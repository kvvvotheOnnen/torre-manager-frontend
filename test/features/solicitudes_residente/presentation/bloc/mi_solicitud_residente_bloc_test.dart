import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:torre_manager_frontend/core/errors/failures.dart';
import 'package:torre_manager_frontend/features/solicitudes_residente/domain/entities/solicitud_residente.dart';
import 'package:torre_manager_frontend/features/solicitudes_residente/domain/repositories/solicitudes_residente_repository.dart';
import 'package:torre_manager_frontend/features/solicitudes_residente/domain/usecases/listar_mis_solicitudes_usecase.dart';
import 'package:torre_manager_frontend/features/solicitudes_residente/presentation/bloc/mi_solicitud_residente_bloc.dart';

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

class _FakeRepository implements SolicitudesResidenteRepository {
  @override
  Future<Either<Failure, List<SolicitudResidente>>> listarMias() async =>
      const Right([_pendiente]);

  @override
  Future<Either<Failure, List<SolicitudResidente>>> listarPendientes() async =>
      const Right([]);

  @override
  Future<Either<Failure, List<SolicitudResidente>>> listarHistorial() async =>
      const Right([]);

  @override
  Future<Either<Failure, SolicitudResidente>> aprobar(String id) async =>
      const Right(_pendiente);

  @override
  Future<Either<Failure, SolicitudResidente>> rechazar(
    String id,
    String motivo,
  ) async => const Right(_pendiente);
}

void main() {
  test('carga la solicitud propia y expone la última', () async {
    final bloc = MiSolicitudResidenteBloc(
      ListarMisSolicitudesUseCase(_FakeRepository()),
    );

    final esperado = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<MiSolicitudState>().having(
          (s) => s.status,
          'status',
          MiSolicitudStatus.cargando,
        ),
        isA<MiSolicitudState>()
            .having((s) => s.status, 'status', MiSolicitudStatus.cargada)
            .having(
              (s) => s.ultima?.estado,
              'ultima',
              EstadoSolicitud.pendiente,
            ),
      ]),
    );

    bloc.add(const MiSolicitudCargada());
    await esperado;
    await bloc.close();
  });
}
