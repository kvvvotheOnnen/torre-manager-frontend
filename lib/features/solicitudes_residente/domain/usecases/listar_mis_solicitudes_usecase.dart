import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/solicitud_residente.dart';
import '../repositories/solicitudes_residente_repository.dart';

class ListarMisSolicitudesUseCase {
  const ListarMisSolicitudesUseCase(this._repository);

  final SolicitudesResidenteRepository _repository;

  Future<Either<Failure, List<SolicitudResidente>>> call() =>
      _repository.listarMias();
}
