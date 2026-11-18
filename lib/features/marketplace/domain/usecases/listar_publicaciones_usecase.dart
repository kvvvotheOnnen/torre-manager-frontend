import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/estado_publicacion.dart';
import '../entities/publicacion_marketplace.dart';
import '../repositories/marketplace_repository.dart';

class ListarPublicacionesUseCase {
  const ListarPublicacionesUseCase(this._repository);

  final MarketplaceRepositoryInterface _repository;

  Future<Either<Failure, List<PublicacionMarketplace>>> call({
    bool todas = false,
    EstadoPublicacion? estado,
  }) {
    return _repository.listar(todas: todas, estado: estado);
  }
}
