import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/paquete.dart';
import '../repositories/paqueteria_repository.dart';

class MarcarPaqueteRetiradoUseCase {
  const MarcarPaqueteRetiradoUseCase(this._repository);

  final PaqueteriaRepositoryInterface _repository;

  Future<Either<Failure, Paquete>> call(String id, String retiradoPorNombre) {
    return _repository.marcarRetirado(id, retiradoPorNombre);
  }
}
