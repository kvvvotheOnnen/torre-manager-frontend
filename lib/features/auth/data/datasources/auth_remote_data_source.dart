import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../models/auth_response_dto.dart';
import '../models/usuario_dto.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  /// Realiza el login contra la API.
  ///
  /// El backend devuelve, en una sola petición:
  /// `{ "access_token": "...", "token_type": "Bearer", "user": { ... } }`.
  Future<AuthResponseDTO> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      AppConfig.loginPath,
      data: {'email': email, 'password': password},
    );

    return AuthResponseDTO.fromJson(response.data ?? const <String, dynamic>{});
  }

  /// Recupera el usuario autenticado con el token almacenado.
  Future<UsuarioDTO> me() async {
    final response = await _dio.get<Map<String, dynamic>>(AppConfig.userPath);

    return UsuarioDTO.fromJson(response.data ?? const <String, dynamic>{});
  }
}
