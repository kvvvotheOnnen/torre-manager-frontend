import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../models/agrupacion_dto.dart';
import '../models/arbol_infraestructura_dto.dart';
import '../models/proyecto_dto.dart';
import '../models/unidad_accesoria_dto.dart';

class InfraestructuraRemoteDataSource {
  const InfraestructuraRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ProyectoDTO> obtenerProyectoDelUsuario() async {
    final response = await _dio.get<Map<String, dynamic>>(
      AppConfig.infraestructuraProyectoPath,
    );

    return ProyectoDTO.fromJson(response.data ?? const <String, dynamic>{});
  }

  Future<List<ProyectoDTO>> listarProyectos() async {
    final response = await _dio.get<List<dynamic>>(
      AppConfig.infraestructuraProyectosPath,
    );

    return (response.data ?? const [])
        .map((item) => ProyectoDTO.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ProyectoDTO> crearProyecto({
    required String nombre,
    String? descripcion,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      AppConfig.infraestructuraProyectosPath,
      data: {'nombre': nombre, 'descripcion': ?descripcion},
    );

    return ProyectoDTO.fromJson(response.data ?? const <String, dynamic>{});
  }

  Future<AgrupacionDTO> registrarAgrupacionEnCascada({
    required String nombre,
    required String tipo,
    String? prefijo,
    required int pisoDesde,
    required int pisoHasta,
    required int unidadesPorPiso,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      AppConfig.infraestructuraAgrupacionesPath,
      data: {
        'nombre': nombre,
        'tipo': tipo,
        if (prefijo != null && prefijo.isNotEmpty) 'prefijo': prefijo,
        'piso_desde': pisoDesde,
        'piso_hasta': pisoHasta,
        'unidades_por_piso': unidadesPorPiso,
      },
    );

    return AgrupacionDTO.fromJson(response.data ?? const <String, dynamic>{});
  }

  Future<List<String>> vistaPreviaIdentificaciones({
    String? prefijo,
    required int pisoDesde,
    required int pisoHasta,
    required int unidadesPorPiso,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      AppConfig.infraestructuraVistaPreviaPath,
      data: {
        if (prefijo != null && prefijo.isNotEmpty) 'prefijo': prefijo,
        'piso_desde': pisoDesde,
        'piso_hasta': pisoHasta,
        'unidades_por_piso': unidadesPorPiso,
      },
    );

    final identificadores =
        (response.data?['identificadores'] ?? const []) as List;

    return identificadores.cast<String>();
  }

  Future<UnidadAccesoriaDTO> crearUnidadAccesoria({
    required String identificador,
    required String tipo,
    required String? asignacion,
    String? unidadPrincipalId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      AppConfig.infraestructuraUnidadesAccesoriasPath,
      data: {
        'identificador': identificador,
        'tipo': tipo,
        'asignacion': ?asignacion,
        'unidad_principal_id': ?unidadPrincipalId,
      },
    );

    return UnidadAccesoriaDTO.fromJson(
      response.data ?? const <String, dynamic>{},
    );
  }

  Future<List<UnidadAccesoriaDTO>> crearUnidadesAccesoriasEnLote({
    required String proyectoId,
    required String tipo,
    required int cantidad,
    String? asignacion,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      AppConfig.infraestructuraUnidadesAccesoriasLotePath,
      data: {
        'proyecto_id': proyectoId,
        'tipo': tipo,
        'cantidad': cantidad,
        'asignacion': ?asignacion,
      },
    );

    final unidades = (response.data?['unidades'] ?? const []) as List;

    return unidades
        .map(
          (item) => UnidadAccesoriaDTO.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<UnidadAccesoriaDTO> asignarUnidadAccesoria({
    required String unidadAccesoriaId,
    required String? asignacion,
    String? unidadPrincipalId,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '${AppConfig.infraestructuraUnidadesAccesoriasPath}/$unidadAccesoriaId/asignacion',
      data: {
        'asignacion': ?asignacion,
        'unidad_principal_id': unidadPrincipalId,
      },
    );

    return UnidadAccesoriaDTO.fromJson(
      response.data ?? const <String, dynamic>{},
    );
  }

  Future<ArbolInfraestructuraDTO> obtenerArbol({
    required String proyectoId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      AppConfig.infraestructuraArbolPath,
      queryParameters: {'proyecto_id': proyectoId},
    );

    return ArbolInfraestructuraDTO.fromJson(
      response.data ?? const <String, dynamic>{},
    );
  }
}
