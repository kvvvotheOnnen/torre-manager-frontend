import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../../domain/entities/definicion_agrupacion.dart';
import '../../domain/entities/instalacion_extra.dart';
import '../../domain/entities/modulo_sistema.dart';
import '../../domain/entities/tipo_condominio.dart';
import '../models/administrador_dto.dart';
import '../models/proyecto_detalle_dto.dart';
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

  Future<ProyectoDetalleDTO> crearProyecto({
    required String nombre,
    String? descripcion,
    required TipoCondominio tipoCondominio,
    required List<ModuloSistema> modulos,
    required List<DefinicionAgrupacion> agrupaciones,
    required List<InstalacionExtra> instalaciones,
    required List<String> adminIds,
    int estacionamientos = 0,
    int bodegas = 0,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      AppConfig.superadminProyectosPath,
      data: {
        'nombre': nombre,
        'descripcion': ?descripcion,
        'tipo_condominio': tipoCondominio.name,
        'modulos': modulos.map((modulo) => modulo.valor).toList(),
        'agrupaciones': agrupaciones
            .map(
              (agrupacion) => {
                'nombre': agrupacion.nombre,
                'tipo': agrupacion.tipo.name,
                'prefijo': ?agrupacion.prefijo,
                'piso_desde': ?agrupacion.pisoDesde,
                'piso_hasta': ?agrupacion.pisoHasta,
                'unidades_por_piso': ?agrupacion.unidadesPorPiso,
                'cantidad': ?agrupacion.cantidad,
              },
            )
            .toList(),
        'instalaciones': instalaciones
            .map(
              (instalacion) => {
                'nombre': instalacion.nombre,
                'capacidad': instalacion.capacidad,
                'descripcion': ?instalacion.descripcion,
                if (instalacion.atributos.isNotEmpty)
                  'atributos': instalacion.atributos,
              },
            )
            .toList(),
        'admin_ids': adminIds,
        if (estacionamientos > 0) 'estacionamientos': estacionamientos,
        if (bodegas > 0) 'bodegas': bodegas,
      },
    );

    return ProyectoDetalleDTO.fromJson(
      response.data ?? const <String, dynamic>{},
    );
  }

  Future<ProyectoDetalleDTO> obtenerProyecto(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      AppConfig.superadminProyectoPath(id),
    );

    return ProyectoDetalleDTO.fromJson(
      response.data ?? const <String, dynamic>{},
    );
  }

  Future<ProyectoDetalleDTO> actualizarProyecto({
    required String id,
    required String nombre,
    String? descripcion,
    required List<ModuloSistema> modulos,
    required List<InstalacionExtra> instalaciones,
    required List<String> adminIds,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      AppConfig.superadminProyectoPath(id),
      data: {
        'nombre': nombre,
        'descripcion': ?descripcion,
        'modulos': modulos.map((modulo) => modulo.valor).toList(),
        'instalaciones': instalaciones
            .map(
              (instalacion) => {
                'nombre': instalacion.nombre,
                'capacidad': instalacion.capacidad,
                'descripcion': ?instalacion.descripcion,
                if (instalacion.atributos.isNotEmpty)
                  'atributos': instalacion.atributos,
              },
            )
            .toList(),
        'admin_ids': adminIds,
      },
    );

    return ProyectoDetalleDTO.fromJson(
      response.data ?? const <String, dynamic>{},
    );
  }

  Future<List<ProyectoDetalleDTO>> listarMisProyectos() async {
    final response = await _dio.get<Map<String, dynamic>>(
      AppConfig.misProyectosPath,
    );

    final proyectos = (response.data?['proyectos'] ?? const []) as List;

    return proyectos
        .map(
          (item) => ProyectoDetalleDTO.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
