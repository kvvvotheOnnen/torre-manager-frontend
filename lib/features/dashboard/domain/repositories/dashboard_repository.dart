import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/modulo_dashboard.dart';

abstract interface class DashboardRepository {
  Future<Either<Failure, List<ModuloDashboard>>> listarModulos();
}
