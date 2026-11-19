import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';

import '../../../../core/config/app_config.dart';
import '../models/documento_asistente_dto.dart';

class AsistenteAdminRemoteDataSource {
  const AsistenteAdminRemoteDataSource(this._client);

  final ApiClient _client;

  Future<DocumentoAsistenteDto?> obtenerDocumento() async {
    final response = await _client.get<Map<String, dynamic>>(
      AppConfig.asistenteAdminDocumentoPath,
    );

    final documento = response.data?['documento'];
    if (documento is! Map<String, dynamic>) {
      return null;
    }

    return DocumentoAsistenteDto.fromJson(documento);
  }

  Future<DocumentoAsistenteDto> subirDocumento({
    required List<int> bytes,
    required String nombre,
  }) async {
    final formData = FormData.fromMap({
      'archivo': MultipartFile.fromBytes(
        bytes,
        filename: nombre,
        contentType: DioMediaType('application', 'pdf'),
      ),
    });

    final response = await _client.post<Map<String, dynamic>>(
      AppConfig.asistenteAdminDocumentoPath,
      data: formData,
    );

    final documento = response.data?['documento'];
    return DocumentoAsistenteDto.fromJson(
      (documento as Map).cast<String, dynamic>(),
    );
  }

  Future<void> eliminarDocumento() async {
    await _client.delete<dynamic>(AppConfig.asistenteAdminDocumentoPath);
  }
}
