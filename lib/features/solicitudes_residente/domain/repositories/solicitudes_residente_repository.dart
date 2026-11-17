import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/solicitud_residente.dart';

abstract interface class SolicitudesResidenteRepository {
  Future<Either<Failure, List<SolicitudResidente>>> listarPendientes();
  Future<Either<Failure, List<SolicitudResidente>>> listarHistorial();
  Future<Either<Failure, SolicitudResidente>> aprobar(String id);
  Future<Either<Failure, SolicitudResidente>> rechazar(
    String id,
    String motivo,
  );
}
