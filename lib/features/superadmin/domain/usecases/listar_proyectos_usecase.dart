import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/resumen_proyecto.dart';
import '../repositories/superadmin_repository.dart';

class ListarProyectosUseCase {
  final SuperadminRepositoryInterface _repository;

  ListarProyectosUseCase(this._repository);

  Future<Either<Failure, List<ResumenProyecto>>> call() {
    return _repository.listarProyectos();
  }
}
