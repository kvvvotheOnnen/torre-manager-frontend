import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/administrador.dart';
import '../entities/resumen_proyecto.dart';

abstract interface class SuperadminRepositoryInterface {
  Future<Either<Failure, List<ResumenProyecto>>> listarProyectos();

  Future<Either<Failure, List<Administrador>>> listarAdministradores();

  Future<Either<Failure, Administrador>> crearAdministrador({
    required String nombre,
    required String correo,
    required String password,
  });
}
