import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/publicacion_marketplace.dart';
import '../repositories/marketplace_repository.dart';

class ListarHistorialMarketplaceUseCase {
  const ListarHistorialMarketplaceUseCase(this._repository);

  final MarketplaceRepositoryInterface _repository;

  Future<Either<Failure, List<PublicacionMarketplace>>> call() {
    return _repository.historial();
  }
}
