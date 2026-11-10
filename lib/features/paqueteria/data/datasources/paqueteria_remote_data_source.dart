import 'package:dio/dio.dart';

import '../../domain/entities/paquete_foto.dart';
import '../models/paquete_dto.dart';

class PaqueteriaRemoteDataSource {
  const PaqueteriaRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> unidades() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/paqueteria/unidades',
    );
    final data = response.data ?? const <String, dynamic>{};
    return (data['unidades'] as List<dynamic>? ?? const [])
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  Future<List<PaqueteDto>> listar() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/paqueteria');
    final data = response.data ?? const <String, dynamic>{};
    final lista = (data['paquetes'] as List<dynamic>? ?? const [])
        .map((e) => PaqueteDto.fromJson(e as Map<String, dynamic>))
        .toList();
    return lista;
  }

  Future<PaqueteDto> registrar({
    required int proyectoId,
    required String descripcion,
    String? remitente,
    int? residenteId,
    int? unidadPrincipalId,
    PaqueteFoto? foto,
  }) async {
    final form = FormData();
    form.fields
      ..add(MapEntry('proyecto_id', '$proyectoId'))
      ..add(MapEntry('descripcion', descripcion));
    if (remitente != null) form.fields.add(MapEntry('remitente', remitente));
    if (residenteId != null) {
      form.fields.add(MapEntry('residente_id', '$residenteId'));
    }
    if (unidadPrincipalId != null) {
      form.fields.add(MapEntry('unidad_principal_id', '$unidadPrincipalId'));
    }
    if (foto != null) {
      form.files.add(
        MapEntry(
          'foto',
          MultipartFile.fromBytes(foto.bytes, filename: foto.nombre),
        ),
      );
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/api/paqueteria',
      data: form,
    );
    return PaqueteDto.fromJson(response.data ?? const <String, dynamic>{});
  }

  Future<PaqueteDto> actualizar({
    required String id,
    String? descripcion,
    String? remitente,
    int? residenteId,
    int? unidadPrincipalId,
    PaqueteFoto? foto,
  }) async {
    final form = FormData();
    if (descripcion != null) {
      form.fields.add(MapEntry('descripcion', descripcion));
    }
    if (remitente != null) form.fields.add(MapEntry('remitente', remitente));
    if (residenteId != null) {
      form.fields.add(MapEntry('residente_id', '$residenteId'));
    }
    if (unidadPrincipalId != null) {
      form.fields.add(MapEntry('unidad_principal_id', '$unidadPrincipalId'));
    }
    if (foto != null) {
      form.files.add(
        MapEntry(
          'foto',
          MultipartFile.fromBytes(foto.bytes, filename: foto.nombre),
        ),
      );
    }

    final response = await _dio.put<Map<String, dynamic>>(
      '/api/paqueteria/$id',
      data: form,
    );
    return PaqueteDto.fromJson(response.data ?? const <String, dynamic>{});
  }

  Future<PaqueteDto> marcarRetirado(String id, String retiradoPorNombre) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/api/paqueteria/$id/retirar',
      data: {'retirado_por_nombre': retiradoPorNombre},
    );
    return PaqueteDto.fromJson(response.data ?? const <String, dynamic>{});
  }
}
