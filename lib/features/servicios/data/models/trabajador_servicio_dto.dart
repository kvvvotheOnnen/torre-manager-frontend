import '../../domain/entities/tipo_servicio.dart';
import '../../domain/entities/trabajador_servicio.dart';

class TrabajadorServicioDto {
  const TrabajadorServicioDto({
    required this.id,
    required this.nombre,
    required this.nombreEmpresa,
    required this.telefono,
    required this.tipo,
    required this.descripcion,
    required this.fotoUrl,
  });

  factory TrabajadorServicioDto.fromJson(Map<String, dynamic> json) {
    return TrabajadorServicioDto(
      id: '${json['id'] ?? ''}',
      nombre: '${json['nombre'] ?? ''}',
      nombreEmpresa: _texto(json['nombre_empresa']),
      telefono: '${json['telefono'] ?? ''}',
      tipo: tipoServicioDesde('${json['tipo_servicio'] ?? ''}'),
      descripcion: _texto(json['descripcion']),
      fotoUrl: _texto(json['foto_url']),
    );
  }

  final String id;
  final String nombre;
  final String? nombreEmpresa;
  final String telefono;
  final TipoServicio tipo;
  final String? descripcion;
  final String? fotoUrl;

  TrabajadorServicio toEntity() {
    return TrabajadorServicio(
      id: id,
      nombre: nombre,
      nombreEmpresa: nombreEmpresa,
      telefono: telefono,
      tipo: tipo,
      descripcion: descripcion,
      fotoUrl: fotoUrl,
    );
  }

  static String? _texto(dynamic valor) {
    if (valor == null) {
      return null;
    }
    final texto = '$valor'.trim();
    return texto.isEmpty ? null : texto;
  }
}
