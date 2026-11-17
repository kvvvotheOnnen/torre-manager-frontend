import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/solicitud_residente.dart';
import '../repositories/solicitudes_residente_repository.dart';

class RechazarSolicitudUseCase {
  const RechazarSolicitudUseCase(this._repository);

  final SolicitudesResidenteRepository _repository;

  Future<Either<Failure, SolicitudResidente>> call(String id, String motivo) =>
      _repository.rechazar(id, motivo);
}
