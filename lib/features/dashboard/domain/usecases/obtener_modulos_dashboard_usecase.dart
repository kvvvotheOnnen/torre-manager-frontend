import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/modulo_dashboard.dart';
import '../repositories/dashboard_repository.dart';

class ObtenerModulosDashboardUseCase {
  const ObtenerModulosDashboardUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Either<Failure, List<ModuloDashboard>>> call() {
    return _repository.listarModulos();
  }
}
