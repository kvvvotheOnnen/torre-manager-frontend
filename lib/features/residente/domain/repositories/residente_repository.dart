import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/mi_informacion.dart';

abstract interface class ResidenteRepositoryInterface {
  Future<Either<Failure, MiInformacion>> obtenerMiInformacion();
}
