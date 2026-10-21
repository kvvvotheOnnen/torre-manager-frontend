import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../models/administrador_dto.dart';
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

  Future<List<AdministradorDTO>> listarAdministradores() async {
    final response = await _dio.get<Map<String, dynamic>>(
      AppConfig.superadminAdministradoresPath,
    );

    final administradores =
        (response.data?['administradores'] ?? const []) as List;

    return administradores
        .map((item) => AdministradorDTO.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<AdministradorDTO> crearAdministrador({
    required String nombre,
    required String correo,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      AppConfig.superadminAdministradoresPath,
      data: {'nombre': nombre, 'email': correo, 'password': password},
    );

    return AdministradorDTO.fromJson(
      response.data ?? const <String, dynamic>{},
    );
  }
}
