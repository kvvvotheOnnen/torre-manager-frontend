import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/core/utils/formato_telefono.dart';

void main() {
  group('formatearTelefono', () {
    test('formatea un móvil chileno sin prefijo', () {
      expect(formatearTelefono('912345678'), '9 1234 5678');
    });

    test('formatea un móvil chileno con prefijo +56', () {
      expect(formatearTelefono('+56912345678'), '+56 9 1234 5678');
    });

    test('agrupa números de largo distinto en bloques de cuatro', () {
      expect(formatearTelefono('22345678'), '2234 5678');
    });

    test('usa el marcador con null, vacío o "null"', () {
      expect(formatearTelefono(null), '-');
      expect(formatearTelefono(''), '-');
      expect(formatearTelefono('null'), '-');
    });
  });
}
