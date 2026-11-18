import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/funcion_dashboard.dart';
import '../repositories/funciones_dashboard_repository.dart';

class ObtenerFuncionesDashboardUseCase {
  const ObtenerFuncionesDashboardUseCase(this._repository);

  final FuncionesDashboardRepository _repository;

  Future<Either<Failure, List<FuncionDashboard>>> call() {
    return _repository.listarFunciones();
  }
}
