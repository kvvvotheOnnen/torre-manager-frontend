import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/core/utils/rut_validator.dart';

void main() {
  group('RutValidator', () {
    test('acepta RUT válidos', () {
      expect(RutValidator.esValido('12.345.678-5'), isTrue);
      expect(RutValidator.esValido('15000002-5'), isTrue);
      expect(RutValidator.esValido('11111111-1'), isTrue);
      expect(RutValidator.esValido('22222222-2'), isTrue);
    });

    test('rechaza RUT con dígito verificador inválido', () {
      expect(RutValidator.validar('12345678-9'), 'Dígito verificador inválido');
    });

    test('rechaza RUT vacío o con formato inválido', () {
      expect(RutValidator.validar(''), 'Ingresa el RUT');
      expect(RutValidator.validar('1'), 'RUT inválido');
      expect(RutValidator.validar('00000000-0'), 'RUT inválido');
    });

    test('formatea y limpia el RUT', () {
      expect(RutValidator.formatear('123456785'), '12.345.678-5');
      expect(RutValidator.limpiar('12.345.678-5'), '123456785');
    });
  });
}
