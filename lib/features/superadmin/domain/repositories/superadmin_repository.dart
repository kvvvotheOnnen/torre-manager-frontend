import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/resumen_proyecto.dart';

abstract interface class SuperadminRepositoryInterface {
  Future<Either<Failure, List<ResumenProyecto>>> listarProyectos();
}
