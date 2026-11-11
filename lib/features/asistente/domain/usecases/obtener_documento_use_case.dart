import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/documento_asistente.dart';
import '../repositories/asistente_admin_repository.dart';

class ObtenerDocumentoUseCase {
  const ObtenerDocumentoUseCase(this._repository);

  final AsistenteAdminRepositoryInterface _repository;

  Future<Either<Failure, DocumentoAsistente?>> call() {
    return _repository.obtenerDocumento();
  }
}
