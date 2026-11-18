import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../../domain/entities/tipo_servicio.dart';
import '../../domain/entities/trabajador_servicio_foto.dart';
import '../models/trabajador_servicio_dto.dart';

class ServiciosRemoteDataSource {
  const ServiciosRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<TrabajadorServicioDto>> listar({
    TipoServicio? tipo,
    String? buscar,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      AppConfig.serviciosPath,
      queryParameters: {
        if (tipo != null) 'tipo': tipo.valor,
        if (buscar != null && buscar.trim().isNotEmpty) 'buscar': buscar.trim(),
      },
    );

    final items =
        response.data?['trabajadores'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map>()
        .map(
          (item) => TrabajadorServicioDto.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<TrabajadorServicioDto> crear({
    required String nombre,
    String? nombreEmpresa,
    required String telefono,
    required TipoServicio tipo,
    String? descripcion,
    TrabajadorServicioFoto? foto,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      AppConfig.serviciosPath,
      data: _formulario(
        nombre: nombre,
        nombreEmpresa: nombreEmpresa,
        telefono: telefono,
        tipo: tipo,
        descripcion: descripcion,
        foto: foto,
      ),
    );
    return _leerTrabajador(response.data);
  }

  Future<TrabajadorServicioDto> actualizar({
    required String id,
    required String nombre,
    String? nombreEmpresa,
    required String telefono,
    required TipoServicio tipo,
    String? descripcion,
    TrabajadorServicioFoto? foto,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      AppConfig.servicioPath(id),
      data: _formulario(
        nombre: nombre,
        nombreEmpresa: nombreEmpresa,
        telefono: telefono,
        tipo: tipo,
        descripcion: descripcion,
        foto: foto,
      ),
    );
    return _leerTrabajador(response.data);
  }

  Future<void> eliminar(String id) async {
    await _dio.delete<void>(AppConfig.servicioPath(id));
  }

  TrabajadorServicioDto _leerTrabajador(Map<String, dynamic>? data) {
    final trabajador = data?['trabajador'];
    if (trabajador is! Map) {
      throw const FormatException('Respuesta inesperada del servidor.');
    }
    return TrabajadorServicioDto.fromJson(
      Map<String, dynamic>.from(trabajador),
    );
  }

  FormData _formulario({
    required String nombre,
    String? nombreEmpresa,
    required String telefono,
    required TipoServicio tipo,
    String? descripcion,
    TrabajadorServicioFoto? foto,
  }) {
    final form = FormData();
    form.fields
      ..add(MapEntry('nombre', nombre))
      ..add(MapEntry('telefono', telefono))
      ..add(MapEntry('tipo_servicio', tipo.valor));

    final empresa = nombreEmpresa?.trim();
    if (empresa != null && empresa.isNotEmpty) {
      form.fields.add(MapEntry('nombre_empresa', empresa));
    }

    final detalle = descripcion?.trim();
    if (detalle != null && detalle.isNotEmpty) {
      form.fields.add(MapEntry('descripcion', detalle));
    }

    if (foto != null) {
      form.files.add(
        MapEntry(
          'foto',
          MultipartFile.fromBytes(foto.bytes, filename: foto.nombre),
        ),
      );
    }

    return form;
  }
}
