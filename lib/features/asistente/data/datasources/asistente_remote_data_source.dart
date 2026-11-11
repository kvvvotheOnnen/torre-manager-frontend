import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../models/respuesta_asistente_dto.dart';

class AsistenteRemoteDataSource {
  const AsistenteRemoteDataSource(this._dio);

  final Dio _dio;

  Future<RespuestaAsistenteDto> consultar(String pregunta) async {
    final response = await _dio.post<Map<String, dynamic>>(
      AppConfig.residenteAsistenteConsultasPath,
      data: {'pregunta': pregunta},
    );

    return RespuestaAsistenteDto.fromJson(
      response.data ?? const <String, dynamic>{},
    );
  }
}
