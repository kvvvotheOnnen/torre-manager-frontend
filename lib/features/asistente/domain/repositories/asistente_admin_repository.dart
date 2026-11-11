import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/documento_asistente.dart';

abstract interface class AsistenteAdminRepositoryInterface {
  Future<Either<Failure, DocumentoAsistente?>> obtenerDocumento();

  Future<Either<Failure, DocumentoAsistente>> subirDocumento({
    required List<int> bytes,
    required String nombre,
  });

  Future<Either<Failure, void>> eliminarDocumento();
}
