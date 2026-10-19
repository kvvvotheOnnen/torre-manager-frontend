import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/usuario.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepositoryInterface _repository;

  Future<Either<Failure, Usuario>> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email.trim(), password);
  }
}
