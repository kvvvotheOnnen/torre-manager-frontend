import '../../domain/entities/documento_asistente.dart';

class DocumentoAsistenteDto {
  const DocumentoAsistenteDto({
    required this.id,
    required this.nombre,
    required this.paginas,
    required this.tamanoTokens,
  });

  final String id;
  final String nombre;
  final int paginas;
  final int tamanoTokens;

  factory DocumentoAsistenteDto.fromJson(Map<String, dynamic> json) {
    return DocumentoAsistenteDto(
      id: '${json['id'] ?? ''}',
      nombre: (json['nombre'] ?? '') as String,
      paginas: (json['paginas'] ?? 0) as int,
      tamanoTokens: (json['tamano_tokens'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'paginas': paginas,
      'tamano_tokens': tamanoTokens,
    };
  }

  DocumentoAsistente toEntity() {
    return DocumentoAsistente(
      id: id,
      nombre: nombre,
      paginas: paginas,
      tamanoTokens: tamanoTokens,
    );
  }
}
