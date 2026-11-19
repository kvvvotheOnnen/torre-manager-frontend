import '../../../../core/network/api_client.dart';

import '../../../../core/config/app_config.dart';
import '../models/mi_informacion_dto.dart';

class ResidenteRemoteDataSource {
  const ResidenteRemoteDataSource(this._client);

  final ApiClient _client;

  Future<MiInformacionDto> miInformacion() async {
    final response = await _client.get<Map<String, dynamic>>(
      AppConfig.residenteMiInformacionPath,
    );
    return MiInformacionDto.fromJson(response.data ?? const <String, dynamic>{});
  }
}
