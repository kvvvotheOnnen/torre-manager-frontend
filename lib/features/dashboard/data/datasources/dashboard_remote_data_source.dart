import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../models/modulo_dashboard_dto.dart';

class DashboardRemoteDataSource {
  const DashboardRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<ModuloDashboardDTO>> listarModulos() async {
    final response = await _dio.get<Map<String, dynamic>>(
      AppConfig.dashboardModulosPath,
    );

    final modulos = (response.data?['modulos'] ?? const []) as List;

    return modulos
        .map(
          (item) => ModuloDashboardDTO.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
