import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/solicitud_residente.dart';
import '../repositories/solicitudes_residente_repository.dart';

class AprobarSolicitudUseCase {
  const AprobarSolicitudUseCase(this._repository);

  final SolicitudesResidenteRepository _repository;

  Future<Either<Failure, SolicitudResidente>> call(String id) =>
      _repository.aprobar(id);
}
