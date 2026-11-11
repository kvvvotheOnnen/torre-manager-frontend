import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/features/asistente/data/models/documento_asistente_dto.dart';
import 'package:torre_manager_frontend/features/asistente/data/models/respuesta_asistente_dto.dart';

void main() {
  test('DocumentoAsistenteDto parsea y convierte a entidad', () {
    final dto = DocumentoAsistenteDto.fromJson({
      'id': 3,
      'nombre': 'reglamento.pdf',
      'paginas': 2,
      'tamano_tokens': 850,
    });

    expect(dto.id, '3');
    expect(dto.nombre, 'reglamento.pdf');
    final entidad = dto.toEntity();
    expect(entidad.paginas, 2);
    expect(entidad.tamanoTokens, 850);
  });

  test('RespuestaAsistenteDto parsea fuentes y tolera ausentes', () {
    final dto = RespuestaAsistenteDto.fromJson({
      'respuesta': 'El quincho está en el piso 7 [Página 1].',
      'fuentes': [
        {'documento': 'reglamento.pdf', 'pagina': 1},
      ],
    });

    final entidad = dto.toEntity();
    expect(entidad.respuesta, contains('piso 7'));
    expect(entidad.fuentes, hasLength(1));
    expect(entidad.fuentes.first.pagina, 1);

    final vacia = RespuestaAsistenteDto.fromJson(const {});
    expect(vacia.toEntity().fuentes, isEmpty);
  });
}
