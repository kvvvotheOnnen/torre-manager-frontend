import 'package:equatable/equatable.dart';

import 'fuente_asistente.dart';

class RespuestaAsistente extends Equatable {
  const RespuestaAsistente({required this.respuesta, required this.fuentes});

  final String respuesta;
  final List<FuenteAsistente> fuentes;

  @override
  List<Object?> get props => [respuesta, fuentes];
}
