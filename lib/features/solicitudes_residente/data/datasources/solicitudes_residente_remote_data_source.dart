import '../../../../core/network/api_client.dart';

import '../../../../core/config/app_config.dart';
import '../models/solicitud_residente_dto.dart';

class SolicitudesResidenteRemoteDataSource {
  const SolicitudesResidenteRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<SolicitudResidenteDTO>> listarPendientes() async {
    final response = await _client.get<Map<String, dynamic>>(
      AppConfig.solicitudesResidentesPath,
    );
    return _parseLista(response.data);
  }

  Future<List<SolicitudResidenteDTO>> listarHistorial() async {
    final response = await _client.get<Map<String, dynamic>>(
      AppConfig.solicitudesResidentesHistorialPath,
    );
    return _parseLista(response.data);
  }

  Future<List<SolicitudResidenteDTO>> listarMias() async {
    final response = await _client.get<Map<String, dynamic>>(
      AppConfig.misSolicitudesResidentesPath,
    );
    return _parseLista(response.data);
  }

  Future<SolicitudResidenteDTO> aprobar(String id) async {
    final response = await _client.post<Map<String, dynamic>>(
      AppConfig.solicitudResidenteAprobarPath(id),
    );
    return SolicitudResidenteDTO.fromJson(response.data ?? const {});
  }

  Future<SolicitudResidenteDTO> rechazar(String id, String motivo) async {
    final response = await _client.post<Map<String, dynamic>>(
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
