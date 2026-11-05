import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import '../tenant/proyecto_activo_store.dart';

class DioClient {
  DioClient(this._tokenStorage, this._proyectoActivoStore, {Dio? dio})
    : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: const {'Accept': 'application/json'},
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          final proyectoId = await _proyectoActivoStore.readProyectoId();
          if (proyectoId != null && proyectoId.isNotEmpty) {
            options.headers['X-Proyecto-Id'] = proyectoId;
          }

          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;
  final ProyectoActivoStore _proyectoActivoStore;

  Dio get dio => _dio;
}
