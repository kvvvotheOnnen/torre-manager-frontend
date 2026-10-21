import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._loginUseCase, this._repository) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  final LoginUseCase _loginUseCase;
  final AuthRepositoryInterface _repository;

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _loginUseCase(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (usuario) => emit(AuthSuccess(usuario)),
    );
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthInitial) return;

    final result = await _repository.obtenerUsuarioAutenticado();

    result.fold(
      (_) => emit(const AuthUnauthenticated()),
      (usuario) => emit(AuthSuccess(usuario)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.cerrarSesion();
    emit(const AuthUnauthenticated());
  }
}
