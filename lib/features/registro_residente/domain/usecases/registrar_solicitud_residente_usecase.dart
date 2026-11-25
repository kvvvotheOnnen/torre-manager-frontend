import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/registro_residente.dart';
import '../repositories/registro_residente_repository.dart';

class RegistrarSolicitudResidenteUseCase {
  const RegistrarSolicitudResidenteUseCase(this._repository);

  final RegistroResidenteRepository _repository;

  Future<Either<Failure, String>> call(SolicitudRegistro solicitud) =>
      _repository.registrar(solicitud);
}
