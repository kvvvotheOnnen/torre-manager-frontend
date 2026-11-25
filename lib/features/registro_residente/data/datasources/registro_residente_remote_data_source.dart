import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../models/registro_residente_dto.dart';

class RegistroResidenteRemoteDataSource {
  const RegistroResidenteRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<ProyectoRegistroDTO>> listarProyectos() async {
    final response = await _client.get<Map<String, dynamic>>(
      AppConfig.registroProyectosPath,
    );

    return (response.data?['proyectos'] as List<dynamic>? ?? const [])
        .map((e) => ProyectoRegistroDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<UnidadRegistroDTO>> listarUnidades(String proyectoId) async {
    final response = await _client.get<Map<String, dynamic>>(
      AppConfig.registroUnidadesPath(proyectoId),
    );

    return (response.data?['unidades'] as List<dynamic>? ?? const [])
        .map((e) => UnidadRegistroDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> registrar(SolicitudRegistroDTO solicitud) async {
    final response = await _client.post<Map<String, dynamic>>(
      AppConfig.registroSolicitudPath,
      data: solicitud.toJson(),
    );

    return (response.data?['message'] ?? 'Solicitud registrada.') as String;
  }
}
