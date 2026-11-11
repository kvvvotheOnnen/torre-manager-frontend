import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../models/documento_asistente_dto.dart';

class AsistenteAdminRemoteDataSource {
  const AsistenteAdminRemoteDataSource(this._dio);

  final Dio _dio;

  Future<DocumentoAsistenteDto?> obtenerDocumento() async {
    final response = await _dio.get<Map<String, dynamic>>(
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

    final response = await _dio.post<Map<String, dynamic>>(
      AppConfig.asistenteAdminDocumentoPath,
      data: formData,
    );

    final documento = response.data?['documento'];
    return DocumentoAsistenteDto.fromJson(
      (documento as Map).cast<String, dynamic>(),
    );
  }

  Future<void> eliminarDocumento() async {
    await _dio.delete<dynamic>(AppConfig.asistenteAdminDocumentoPath);
  }
}
