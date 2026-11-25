import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/notificacion.dart';

abstract interface class NotificacionesRepositoryInterface {
  Future<Either<Failure, List<Notificacion>>> listar();

  Future<Either<Failure, int>> contarNoLeidas();

  Future<Either<Failure, Notificacion>> marcarLeida(String id);

  Future<Either<Failure, int>> marcarTodasLeidas();
}
