import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/solicitudes_marketplace.dart';
import '../repositories/marketplace_repository.dart';

class ListarSolicitudesUseCase {
  const ListarSolicitudesUseCase(this._repository);

  final MarketplaceRepositoryInterface _repository;

  Future<Either<Failure, SolicitudesMarketplace>> call() async {
    return _repository.solicitudes();
  }
}
