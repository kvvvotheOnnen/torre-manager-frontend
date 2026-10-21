import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/administrador.dart';
import '../repositories/superadmin_repository.dart';

class CrearAdministradorUseCase {
  static const int passwordMinLength = 8;

  final SuperadminRepositoryInterface _repository;

  CrearAdministradorUseCase(this._repository);

  Future<Either<Failure, Administrador>> call({
    required String nombre,
    required String correo,
    required String password,
  }) {
    final nombreTrim = nombre.trim();
    final correoTrim = correo.trim();

    if (nombreTrim.isEmpty) {
      return Future.value(
        Left(ValidationFailure('El nombre del administrador es obligatorio.')),
      );
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(correoTrim)) {
      return Future.value(
        Left(ValidationFailure('El correo electrónico no es válido.')),
      );
    }
    if (password.length < passwordMinLength) {
      return Future.value(
        Left(
          ValidationFailure(
            'La contraseña debe tener al menos $passwordMinLength caracteres.',
          ),
        ),
      );
    }

    return _repository.crearAdministrador(
      nombre: nombreTrim,
      correo: correoTrim,
      password: password,
    );
  }
}
