import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/categoria_producto.dart';
import '../entities/condicion_producto.dart';
import '../entities/estado_publicacion.dart';
import '../entities/publicacion_foto.dart';
import '../entities/publicacion_marketplace.dart';
import '../entities/solicitudes_marketplace.dart';

abstract interface class MarketplaceRepositoryInterface {
  Future<Either<Failure, List<PublicacionMarketplace>>> listar({
    bool todas = false,
    EstadoPublicacion? estado,
  });

  Future<Either<Failure, List<PublicacionMarketplace>>> misPublicaciones();

  Future<Either<Failure, List<PublicacionMarketplace>>> historial();

  Future<Either<Failure, List<PublicacionMarketplace>>> favoritos();

  Future<Either<Failure, PublicacionMarketplace>> crear({
    required String titulo,
    required String descripcion,
    required int precio,
    required CategoriaProducto categoria,
    required CondicionProducto condicion,
    PublicacionFoto? foto,
  });

  Future<Either<Failure, PublicacionMarketplace>> actualizar({
    required String id,
    required String titulo,
    required String descripcion,
    required int precio,
    required CategoriaProducto categoria,
    required CondicionProducto condicion,
    PublicacionFoto? foto,
  });

  Future<Either<Failure, PublicacionMarketplace>> retirar(String id);

  Future<Either<Failure, PublicacionMarketplace>> vender(String id);

  Future<Either<Failure, bool>> eliminar({
    required String id,
    required String motivo,
  });

  Future<Either<Failure, SolicitudesMarketplace>> solicitudes();

  Future<Either<Failure, PublicacionMarketplace>> aprobarSolicitud(String id);

  Future<Either<Failure, PublicacionMarketplace>> rechazarSolicitud({
    required String id,
    required String motivo,
  });

  Future<Either<Failure, bool>> alternarFavorito({
    required String id,
    required bool favorito,
  });
}
