import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/notificaciones_repository.dart';

class MarcarTodasNotificacionesLeidasUseCase {
  const MarcarTodasNotificacionesLeidasUseCase(this._repository);

  final NotificacionesRepositoryInterface _repository;

  Future<Either<Failure, int>> call() => _repository.marcarTodasLeidas();
}
