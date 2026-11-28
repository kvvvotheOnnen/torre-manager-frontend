import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/publicacion_marketplace.dart';
import '../repositories/marketplace_repository.dart';

class AprobarSolicitudMarketplaceUseCase {
  const AprobarSolicitudMarketplaceUseCase(this._repository);

  final MarketplaceRepositoryInterface _repository;

  Future<Either<Failure, PublicacionMarketplace>> call(String id) async {
    return _repository.aprobarSolicitud(id);
  }
}
