import '../../domain/entities/notificacion.dart';

class NotificacionDto {
  const NotificacionDto({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.leida,
    this.datos,
    this.creadoEn,
  });

  factory NotificacionDto.fromJson(Map<String, dynamic> json) {
    return NotificacionDto(
      id: '${json['id'] ?? ''}',
      tipo: '${json['tipo'] ?? ''}',
      titulo: '${json['titulo'] ?? ''}',
      mensaje: '${json['mensaje'] ?? ''}',
      leida: json['leida'] == true,
      datos: _mapa(json['datos']),
      creadoEn: _fecha(json['creado_en']),
    );
  }

  final String id;
  final String tipo;
  final String titulo;
  final String mensaje;
  final bool leida;
  final Map<String, dynamic>? datos;
  final DateTime? creadoEn;

  Notificacion toEntity() {
    return Notificacion(
      id: id,
      tipo: tipo,
      titulo: titulo,
      mensaje: mensaje,
      leida: leida,
      datos: datos,
      creadoEn: creadoEn,
    );
  }

  static Map<String, dynamic>? _mapa(dynamic valor) {
    if (valor is Map) {
      return Map<String, dynamic>.from(valor);
    }
    return null;
  }

  static DateTime? _fecha(dynamic valor) {
    if (valor is! String || valor.isEmpty) {
      return null;
    }
    return DateTime.tryParse(valor);
  }
}
