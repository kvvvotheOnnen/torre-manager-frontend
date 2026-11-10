import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/paquete.dart';
import '../entities/paquete_foto.dart';
import '../repositories/paqueteria_repository.dart';

class ActualizarPaqueteUseCase {
  const ActualizarPaqueteUseCase(this._repository);

  final PaqueteriaRepositoryInterface _repository;

  Future<Either<Failure, Paquete>> call({
    required String id,
    String? descripcion,
    String? remitente,
    int? residenteId,
    int? unidadPrincipalId,
    PaqueteFoto? foto,
  }) {
    return _repository.actualizar(
      id: id,
      descripcion: descripcion,
      remitente: remitente,
      residenteId: residenteId,
      unidadPrincipalId: unidadPrincipalId,
      foto: foto,
    );
  }
}
