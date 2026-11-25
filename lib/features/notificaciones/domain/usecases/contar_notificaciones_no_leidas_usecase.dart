import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/notificaciones_repository.dart';

class ContarNotificacionesNoLeidasUseCase {
  const ContarNotificacionesNoLeidasUseCase(this._repository);

  final NotificacionesRepositoryInterface _repository;

  Future<Either<Failure, int>> call() => _repository.contarNoLeidas();
}
