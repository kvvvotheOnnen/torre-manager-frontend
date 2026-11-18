import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/publicacion_marketplace.dart';
import '../repositories/marketplace_repository.dart';

class RetirarPublicacionUseCase {
  const RetirarPublicacionUseCase(this._repository);

  final MarketplaceRepositoryInterface _repository;

  Future<Either<Failure, PublicacionMarketplace>> call(String id) {
    return _repository.retirar(id);
  }
}
