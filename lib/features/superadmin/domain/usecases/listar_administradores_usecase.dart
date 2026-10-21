import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/administrador.dart';
import '../repositories/superadmin_repository.dart';

class ListarAdministradoresUseCase {
  final SuperadminRepositoryInterface _repository;

  ListarAdministradoresUseCase(this._repository);

  Future<Either<Failure, List<Administrador>>> call() {
    return _repository.listarAdministradores();
  }
}
