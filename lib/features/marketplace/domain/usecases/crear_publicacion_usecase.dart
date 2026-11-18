import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/categoria_producto.dart';
import '../entities/condicion_producto.dart';
import '../entities/publicacion_foto.dart';
import '../entities/publicacion_marketplace.dart';
import '../repositories/marketplace_repository.dart';

class CrearPublicacionUseCase {
  const CrearPublicacionUseCase(this._repository);

  final MarketplaceRepositoryInterface _repository;

  Future<Either<Failure, PublicacionMarketplace>> call({
    required String titulo,
    required String descripcion,
    required int precio,
    required CategoriaProducto categoria,
    required CondicionProducto condicion,
    PublicacionFoto? foto,
  }) {
    return _repository.crear(
      titulo: titulo,
      descripcion: descripcion,
      precio: precio,
      categoria: categoria,
      condicion: condicion,
      foto: foto,
    );
  }
}
