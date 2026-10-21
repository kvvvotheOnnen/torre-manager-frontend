import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../models/resumen_proyecto_dto.dart';

class SuperadminRemoteDataSource {
  const SuperadminRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<ResumenProyectoDTO>> listarProyectos() async {
    final response = await _dio.get<Map<String, dynamic>>(
      AppConfig.superadminProyectosPath,
    );

    final proyectos = (response.data?['proyectos'] ?? const []) as List;

    return proyectos
        .map(
          (item) => ResumenProyectoDTO.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
