import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../superadmin/domain/entities/proyecto_detalle.dart';
import '../../../superadmin/domain/repositories/superadmin_repository.dart';

class ListarMisProyectosUseCase {
  final SuperadminRepositoryInterface _repository;

  ListarMisProyectosUseCase(this._repository);

  Future<Either<Failure, List<ProyectoDetalle>>> call() {
    return _repository.listarMisProyectos();
  }
}
