import '../../../../core/network/api_client.dart';

import '../../../../core/config/app_config.dart';
import '../models/respuesta_asistente_dto.dart';

class AsistenteRemoteDataSource {
  const AsistenteRemoteDataSource(this._client);

  final ApiClient _client;

  Future<RespuestaAsistenteDto> consultar(String pregunta) async {
    final response = await _client.post<Map<String, dynamic>>(
      AppConfig.residenteAsistenteConsultasPath,
      data: {'pregunta': pregunta},
    );

    return RespuestaAsistenteDto.fromJson(
      response.data ?? const <String, dynamic>{},
    );
  }
}
