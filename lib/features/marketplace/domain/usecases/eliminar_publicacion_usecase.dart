import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/marketplace_repository.dart';

class EliminarPublicacionUseCase {
  const EliminarPublicacionUseCase(this._repository);

  final MarketplaceRepositoryInterface _repository;

  Future<Either<Failure, bool>> call({
    required String id,
    required String motivo,
  }) {
    return _repository.eliminar(id: id, motivo: motivo);
  }
}
