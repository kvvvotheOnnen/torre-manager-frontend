import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/mi_informacion.dart';
import '../repositories/residente_repository.dart';

class ObtenerMiInformacionUseCase {
  const ObtenerMiInformacionUseCase(this._repository);

  final ResidenteRepositoryInterface _repository;

  Future<Either<Failure, MiInformacion>> call() {
    return _repository.obtenerMiInformacion();
  }
}
