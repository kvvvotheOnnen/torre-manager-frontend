import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:torre_manager_frontend/core/errors/failures.dart';
import 'package:torre_manager_frontend/features/auth/domain/entities/usuario.dart';
import 'package:torre_manager_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:torre_manager_frontend/features/auth/domain/usecases/login_usecase.dart';

class _FakeAuthRepository implements AuthRepositoryInterface {
  _FakeAuthRepository(this._result);

  final Either<Failure, Usuario> _result;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<Either<Failure, Usuario>> login(String email, String password) async {
    lastEmail = email;
    lastPassword = password;
    return _result;
  }
}

void main() {
  const usuario = Usuario(
    id: '1',
    nombre: 'Test',
    correo: 'test@example.test',
    rol: Rol.conserje,
  );

  test('retorna el Usuario cuando las credenciales son válidas', () async {
    final repository = _FakeAuthRepository(const Right(usuario));
    final useCase = LoginUseCase(repository);

    final result = await useCase(email: '  test@example.test  ', password: 'p');

    expect(result.isRight(), isTrue);
    expect(result.getOrElse((_) => usuario), usuario);
    expect(repository.lastEmail, 'test@example.test');
  });

  test('retorna un Failure cuando las credenciales son inválidas', () async {
    final repository = _FakeAuthRepository(
      const Left(ServerFailure('Credenciales inválidas')),
    );
    final useCase = LoginUseCase(repository);

    final result = await useCase(email: 'test@example.test', password: 'bad');

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure.message, 'Credenciales inválidas'),
      (_) => fail('Se esperaba un Left'),
    );
  });
}
