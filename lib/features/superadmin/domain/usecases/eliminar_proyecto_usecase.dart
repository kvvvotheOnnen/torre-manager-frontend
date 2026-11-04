import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/superadmin_repository.dart';

class EliminarProyectoUseCase {
  final SuperadminRepositoryInterface _repository;

  EliminarProyectoUseCase(this._repository);

  Future<Either<Failure, void>> call(String id) {
    return _repository.eliminarProyecto(id);
  }
}
