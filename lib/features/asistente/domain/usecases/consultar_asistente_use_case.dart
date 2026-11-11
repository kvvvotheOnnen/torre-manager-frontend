import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/respuesta_asistente.dart';
import '../repositories/asistente_repository.dart';

class ConsultarAsistenteUseCase {
  const ConsultarAsistenteUseCase(this._repository);

  final AsistenteRepositoryInterface _repository;

  Future<Either<Failure, RespuestaAsistente>> call(String pregunta) {
    return _repository.consultar(pregunta);
  }
}
