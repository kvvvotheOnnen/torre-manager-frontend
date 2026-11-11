import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/documento_asistente.dart';
import '../repositories/asistente_admin_repository.dart';

class SubirDocumentoUseCase {
  const SubirDocumentoUseCase(this._repository);

  final AsistenteAdminRepositoryInterface _repository;

  Future<Either<Failure, DocumentoAsistente>> call({
    required List<int> bytes,
    required String nombre,
  }) {
    return _repository.subirDocumento(bytes: bytes, nombre: nombre);
  }
}
