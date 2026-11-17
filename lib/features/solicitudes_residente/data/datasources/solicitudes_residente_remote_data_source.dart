import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../models/solicitud_residente_dto.dart';

class SolicitudesResidenteRemoteDataSource {
  const SolicitudesResidenteRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<SolicitudResidenteDTO>> listarPendientes() async {
    final response = await _dio.get<Map<String, dynamic>>(
      AppConfig.solicitudesResidentesPath,
    );
    return _parseLista(response.data);
  }

  Future<List<SolicitudResidenteDTO>> listarHistorial() async {
    final response = await _dio.get<Map<String, dynamic>>(
      AppConfig.solicitudesResidentesHistorialPath,
    );
    return _parseLista(response.data);
  }

  Future<SolicitudResidenteDTO> aprobar(String id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      AppConfig.solicitudResidenteAprobarPath(id),
    );
    return SolicitudResidenteDTO.fromJson(response.data ?? const {});
  }

  Future<SolicitudResidenteDTO> rechazar(String id, String motivo) async {
    final response = await _dio.post<Map<String, dynamic>>(
      AppConfig.solicitudResidenteRechazarPath(id),
      data: {'motivo': motivo},
    );
    return SolicitudResidenteDTO.fromJson(response.data ?? const {});
  }

  List<SolicitudResidenteDTO> _parseLista(Map<String, dynamic>? data) {
    return (data?['solicitudes'] as List<dynamic>? ?? const [])
        .map((e) => SolicitudResidenteDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
