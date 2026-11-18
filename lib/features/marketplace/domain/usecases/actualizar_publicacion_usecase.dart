import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/categoria_producto.dart';
import '../entities/condicion_producto.dart';
import '../entities/publicacion_foto.dart';
import '../entities/publicacion_marketplace.dart';
import '../repositories/marketplace_repository.dart';

class ActualizarPublicacionUseCase {
  const ActualizarPublicacionUseCase(this._repository);

  final MarketplaceRepositoryInterface _repository;

  Future<Either<Failure, PublicacionMarketplace>> call({
    required String id,
    required String titulo,
    required String descripcion,
    required int precio,
    required CategoriaProducto categoria,
    required CondicionProducto condicion,
    PublicacionFoto? foto,
  }) {
    return _repository.actualizar(
      id: id,
      titulo: titulo,
      descripcion: descripcion,
      precio: precio,
      categoria: categoria,
      condicion: condicion,
      foto: foto,
    );
  }
}
