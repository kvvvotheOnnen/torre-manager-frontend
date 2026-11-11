import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/asistente_admin_repository.dart';

class EliminarDocumentoUseCase {
  const EliminarDocumentoUseCase(this._repository);

  final AsistenteAdminRepositoryInterface _repository;

  Future<Either<Failure, void>> call() {
    return _repository.eliminarDocumento();
  }
}
