import 'package:equatable/equatable.dart';

class Notificacion extends Equatable {
  const Notificacion({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.leida,
    this.datos,
    this.creadoEn,
  });

  final String id;
  final String tipo;
  final String titulo;
  final String mensaje;
  final bool leida;
  final Map<String, dynamic>? datos;
  final DateTime? creadoEn;

  Notificacion copyWith({bool? leida}) {
    return Notificacion(
      id: id,
      tipo: tipo,
      titulo: titulo,
      mensaje: mensaje,
      leida: leida ?? this.leida,
      datos: datos,
      creadoEn: creadoEn,
    );
  }

  @override
  List<Object?> get props => [id, tipo, titulo, mensaje, leida, datos, creadoEn];
}
