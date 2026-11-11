import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/respuesta_asistente.dart';

abstract interface class AsistenteRepositoryInterface {
  Future<Either<Failure, RespuestaAsistente>> consultar(String pregunta);
}
