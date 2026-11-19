import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/unidad_gestionable.dart';
import '../repositories/paqueteria_repository.dart';

class ListarUnidadesUseCase {
  const ListarUnidadesUseCase(this._repository);

  final PaqueteriaRepositoryInterface _repository;

  Future<Either<Failure, List<UnidadGestionable>>> call() {
    return _repository.listarUnidades();
  }
}
