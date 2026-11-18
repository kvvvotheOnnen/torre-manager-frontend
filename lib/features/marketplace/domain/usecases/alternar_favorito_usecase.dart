import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/marketplace_repository.dart';

class AlternarFavoritoUseCase {
  const AlternarFavoritoUseCase(this._repository);

  final MarketplaceRepositoryInterface _repository;

  Future<Either<Failure, bool>> call({
    required String id,
    required bool favorito,
  }) {
    return _repository.alternarFavorito(id: id, favorito: favorito);
  }
}
