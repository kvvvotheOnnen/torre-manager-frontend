import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/usuario.dart';

abstract interface class AuthRepositoryInterface {
  Future<Either<Failure, Usuario>> login(String email, String password);

  Future<Either<Failure, Usuario>> obtenerUsuarioAutenticado();

  Future<void> cerrarSesion();
}
