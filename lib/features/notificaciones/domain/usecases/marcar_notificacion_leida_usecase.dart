import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/notificacion.dart';
import '../repositories/notificaciones_repository.dart';

class MarcarNotificacionLeidaUseCase {
  const MarcarNotificacionLeidaUseCase(this._repository);

  final NotificacionesRepositoryInterface _repository;

  Future<Either<Failure, Notificacion>> call(String id) =>
      _repository.marcarLeida(id);
}
