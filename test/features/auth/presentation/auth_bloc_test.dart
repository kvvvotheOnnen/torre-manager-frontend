import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:torre_manager_frontend/core/errors/failures.dart';
import 'package:torre_manager_frontend/features/auth/domain/entities/usuario.dart';
import 'package:torre_manager_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:torre_manager_frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:torre_manager_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:torre_manager_frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:torre_manager_frontend/features/auth/presentation/bloc/auth_state.dart';

class _FakeAuthRepository implements AuthRepositoryInterface {
  _FakeAuthRepository(this._result);

  final Either<Failure, Usuario> _result;

  @override
  Future<Either<Failure, Usuario>> login(String email, String password) async {
    return _result;
  }
}

void main() {
  const usuario = Usuario(
    id: '1',
    nombre: 'Test',
    correo: 'test@example.test',
    rol: Rol.administrador,
  );

  test('emite AuthLoading y luego AuthSuccess en credenciales válidas', () async {
    final bloc = AuthBloc(LoginUseCase(_FakeAuthRepository(const Right(usuario))));

    final states = <AuthState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(const LoginRequested(email: 'test@example.test', password: 'p'));

    await pumpEventQueue();
    await subscription.cancel();
    await bloc.close();

    expect(states, [
      isA<AuthLoading>(),
      isA<AuthSuccess>(),
    ]);
    expect((states.last as AuthSuccess).usuario, usuario);
  });

  test('emite AuthLoading y luego AuthError en credenciales inválidas', () async {
    final bloc = AuthBloc(
      LoginUseCase(
        _FakeAuthRepository(const Left(ServerFailure('Credenciales inválidas'))),
      ),
    );

    final states = <AuthState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(const LoginRequested(email: 'test@example.test', password: 'bad'));

    await pumpEventQueue();
    await subscription.cancel();
    await bloc.close();

    expect(states, [
      isA<AuthLoading>(),
      isA<AuthError>(),
    ]);
    expect((states.last as AuthError).message, 'Credenciales inválidas');
  });
}
