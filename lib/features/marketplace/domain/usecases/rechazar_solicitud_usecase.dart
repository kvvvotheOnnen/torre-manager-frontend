import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/publicacion_marketplace.dart';
import '../repositories/marketplace_repository.dart';

class RechazarSolicitudMarketplaceUseCase {
  const RechazarSolicitudMarketplaceUseCase(this._repository);

  final MarketplaceRepositoryInterface _repository;

  Future<Either<Failure, PublicacionMarketplace>> call({
    required String id,
    required String motivo,
  }) async {
    return _repository.rechazarSolicitud(id: id, motivo: motivo);
  }
}
