import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/superadmin_repository.dart';

class DescartarProyectoBorradorUseCase {
  const DescartarProyectoBorradorUseCase(this._repository);

  final SuperadminRepositoryInterface _repository;

  Future<Either<Failure, void>> call(String id) {
    return _repository.descartarProyectoBorrador(id);
  }
}
