import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/servicios_repository.dart';

class EliminarTrabajadorUseCase {
  const EliminarTrabajadorUseCase(this._repository);

  final ServiciosRepositoryInterface _repository;

  Future<Either<Failure, bool>> call(String id) => _repository.eliminar(id);
}
