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
        'agrupaciones': _agrupacionesJson(agrupaciones),
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

  Future<ProyectoDetalleDTO> iniciarProyectoBorrador({
    required String nombre,
    String? descripcion,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      AppConfig.superadminProyectosBorradorPath,
      data: {'nombre': nombre, 'descripcion': descripcion},
    );

    return ProyectoDetalleDTO.fromJson(
      response.data ?? const <String, dynamic>{},
    );
  }

  Future<ProyectoDetalleDTO> guardarPasoProyecto({
    required String id,
    required String nombre,
    String? descripcion,
    TipoCondominio? tipoCondominio,
    List<DefinicionAgrupacion>? agrupaciones,
    List<InstalacionExtra>? instalaciones,
    List<ModuloSistema>? modulos,
    List<String>? adminIds,
    bool resetEstructura = false,
    bool finalizar = false,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      AppConfig.superadminProyectoBorradorPath(id),
      data: {
        'nombre': nombre,
        'descripcion': descripcion,
        if (tipoCondominio != null) 'tipo_condominio': tipoCondominio.name,
        if (agrupaciones != null)
          'agrupaciones': _agrupacionesJson(agrupaciones),
        if (instalaciones != null)
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
        if (modulos != null)
          'modulos': modulos.map((modulo) => modulo.valor).toList(),
        'admin_ids': ?adminIds,
        if (resetEstructura) 'reset_estructura': true,
        if (finalizar) 'finalizar': true,
      },
    );

    return ProyectoDetalleDTO.fromJson(
      response.data ?? const <String, dynamic>{},
    );
  }

  Future<void> descartarProyectoBorrador(String id) async {
    await _dio.delete<void>(AppConfig.superadminProyectoBorradorPath(id));
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

  List<Map<String, dynamic>> _agrupacionesJson(
    List<DefinicionAgrupacion> agrupaciones,
  ) {
    return agrupaciones
        .map(
          (agrupacion) => {
            'nombre': agrupacion.nombre,
            'tipo': agrupacion.tipo.name,
            'prefijo': ?agrupacion.prefijo,
            'piso_desde': ?agrupacion.pisoDesde,
            'piso_hasta': ?agrupacion.pisoHasta,
            'unidades_por_piso': ?agrupacion.unidadesPorPiso,
            'cantidad': ?agrupacion.cantidad,
            if (agrupacion.pisosExcepcion.isNotEmpty)
              'pisos_excepcion': agrupacion.pisosExcepcion
                  .map(
                    (piso) => {
                      'piso': piso.piso,
                      if (piso.sinUnidades) 'sin_unidades': true,
                      'unidades': piso.sinUnidades
                          ? const []
                          : piso.unidades
                                .map(
                                  (unidad) => {
                                    'tipo':
                                        unidad.tipo ==
                                            TipoUnidadExcepcion.simple
                                        ? 'simple'
                                        : 'instalacion',
                                    if (unidad.tipo ==
                                        TipoUnidadExcepcion.instalacionExtra)
                                      'identificador': unidad.identificador,
                                  },
                                )
                                .toList(),
                    },
                  )
                  .toList(),
          },
        )
        .toList();
  }

  Future<void> eliminarProyecto(String id) async {
    await _dio.delete<void>(AppConfig.superadminProyectoPath(id));
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
