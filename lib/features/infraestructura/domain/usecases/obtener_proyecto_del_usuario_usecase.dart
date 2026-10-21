import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/proyecto.dart';
import '../repositories/infraestructura_repository.dart';

class ObtenerProyectoDelUsuarioUseCase {
  final InfraestructuraRepositoryInterface _repository;

  ObtenerProyectoDelUsuarioUseCase(this._repository);

  Future<Either<Failure, Proyecto>> call() {
    return _repository.obtenerProyectoDelUsuario();
  }
}
