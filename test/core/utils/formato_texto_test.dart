import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/core/utils/formato_texto.dart';

void main() {
  group('orPlaceholder', () {
    test('devuelve el texto cuando tiene contenido', () {
      expect('Unidad 12'.orPlaceholder(), 'Unidad 12');
    });

    test('reemplaza null, vacío y la cadena "null"', () {
      expect(null.orPlaceholder(), '-');
      expect('   '.orPlaceholder(), '-');
      expect('NULL'.orPlaceholder(), '-');
    });

    test('respeta el marcador personalizado', () {
      expect(null.orPlaceholder('No registrado'), 'No registrado');
    });
  });
}
