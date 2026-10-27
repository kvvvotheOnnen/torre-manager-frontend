import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/proyecto_detalle.dart';
import '../repositories/superadmin_repository.dart';

class ObtenerProyectoUseCase {
  final SuperadminRepositoryInterface _repository;

  ObtenerProyectoUseCase(this._repository);

  Future<Either<Failure, ProyectoDetalle>> call(String id) {
    return _repository.obtenerProyecto(id);
  }
}
