import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepositoryInterface {
  const AuthRepositoryImpl(this._remoteDataSource, this._tokenStorage);

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  @override
  Future<Either<Failure, Usuario>> login(String email, String password) async {
    try {
      final response = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      await _tokenStorage.saveToken(response.accessToken);

      return Right(response.usuario.toEntity());
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        return const Left(ServerFailure('Credenciales inválidas'));
      }
      return const Left(ServerFailure());
    } on FormatException {
      return const Left(ServerFailure());
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}
