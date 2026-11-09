import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../models/mi_informacion_dto.dart';

class ResidenteRemoteDataSource {
  const ResidenteRemoteDataSource(this._dio);

  final Dio _dio;

  Future<MiInformacionDto> miInformacion() async {
    final response = await _dio.get<Map<String, dynamic>>(
      AppConfig.residenteMiInformacionPath,
    );
    return MiInformacionDto.fromJson(response.data ?? const <String, dynamic>{});
  }
}
