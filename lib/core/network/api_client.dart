import 'package:dio/dio.dart';

import '../errors/api_exception.dart';

/// Cliente HTTP de la capa de infraestructura.
///
/// Centraliza la traducción de `DioException` a [ApiException] para que los
/// DataSources no repitan el manejo de códigos de estado y los repositorios no
/// dependan de `dio`.
class ApiClient {
  const ApiClient(this._dio);

  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _run(() => _dio.get<T>(path, queryParameters: queryParameters));
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _run(
      () => _dio.post<T>(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _run(
      () => _dio.put<T>(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _run(
      () => _dio.patch<T>(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _run(
      () => _dio.delete<T>(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<Response<T>> _run<T>(Future<Response<T>> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw ApiException(
        error.response?.statusCode,
        error.response?.data,
      );
    }
  }
}
