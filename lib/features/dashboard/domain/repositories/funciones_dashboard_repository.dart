import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/funcion_dashboard.dart';

abstract interface class FuncionesDashboardRepository {
  Future<Either<Failure, List<FuncionDashboard>>> listarFunciones();
}
