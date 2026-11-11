import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/paquete.dart';
import '../entities/paquete_foto.dart';

abstract interface class PaqueteriaRepositoryInterface {
  Future<Either<Failure, List<Paquete>>> listar();
  Future<Either<Failure, Paquete>> registrar({
    required int proyectoId,
    required String descripcion,
    String? remitente,
    int? residenteId,
    int? unidadPrincipalId,
    PaqueteFoto? foto,
  });
  Future<Either<Failure, Paquete>> marcarRetirado(
    String id,
    String retiradoPorNombre,
  );
  Future<Either<Failure, Paquete>> actualizar({
    required String id,
    String? descripcion,
    String? remitente,
    int? residenteId,
    int? unidadPrincipalId,
    PaqueteFoto? foto,
  });
}
