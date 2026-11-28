import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/notificacion.dart';
import '../repositories/notificaciones_repository.dart';

class ListarNotificacionesUseCase {
  const ListarNotificacionesUseCase(this._repository);

  final NotificacionesRepositoryInterface _repository;

  Future<Either<Failure, List<Notificacion>>> call() => _repository.listar();
}
