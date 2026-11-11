import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/paquete.dart';
import '../repositories/paqueteria_repository.dart';

class ListarPaquetesUseCase {
  const ListarPaquetesUseCase(this._repository);

  final PaqueteriaRepositoryInterface _repository;

  Future<Either<Failure, List<Paquete>>> call() => _repository.listar();
}
