import '../../../../core/network/api_client.dart';

import '../../../../core/config/app_config.dart';
import '../models/funcion_dashboard_dto.dart';

/// Única clase de la feature autorizada a usar `dio`.
class FuncionesDashboardRemoteDataSource {
  const FuncionesDashboardRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<FuncionDashboardDto>> listar() async {
    final respuesta = await _client.get<Map<String, dynamic>>(
      AppConfig.dashboardFuncionesPath,
    );

    final data = respuesta.data?['funciones'];
    final lista = data is List ? data : const [];

    return lista
        .whereType<Map>()
        .map(
          (item) => FuncionDashboardDto.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }
}
