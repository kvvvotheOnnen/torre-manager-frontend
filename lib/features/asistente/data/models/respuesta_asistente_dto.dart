import '../../domain/entities/fuente_asistente.dart';
import '../../domain/entities/respuesta_asistente.dart';

class RespuestaAsistenteDto {
  const RespuestaAsistenteDto({required this.respuesta, required this.fuentes});

  final String respuesta;
  final List<FuenteAsistenteDto> fuentes;

  factory RespuestaAsistenteDto.fromJson(Map<String, dynamic> json) {
    final fuentes = (json['fuentes'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(FuenteAsistenteDto.fromJson)
        .toList();

    return RespuestaAsistenteDto(
      respuesta: (json['respuesta'] ?? '') as String,
      fuentes: fuentes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'respuesta': respuesta,
      'fuentes': fuentes.map((fuente) => fuente.toJson()).toList(),
    };
  }

  RespuestaAsistente toEntity() {
    return RespuestaAsistente(
      respuesta: respuesta,
      fuentes: fuentes.map((fuente) => fuente.toEntity()).toList(),
    );
  }
}

class FuenteAsistenteDto {
  const FuenteAsistenteDto({required this.documento, required this.pagina});

  final String documento;
  final int pagina;

  factory FuenteAsistenteDto.fromJson(Map<String, dynamic> json) {
    return FuenteAsistenteDto(
      documento: (json['documento'] ?? '') as String,
      pagina: (json['pagina'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'documento': documento, 'pagina': pagina};
  }

  FuenteAsistente toEntity() {
    return FuenteAsistente(documento: documento, pagina: pagina);
  }
}
