import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/core/utils/formato_moneda.dart';

void main() {
  test('formatea precios CLP con separador de miles', () {
    expect(formatearPrecio(0), '\$0');
    expect(formatearPrecio(950), '\$950');
    expect(formatearPrecio(1500), '\$1.500');
    expect(formatearPrecio(150000), '\$150.000');
    expect(formatearPrecio(1234567), '\$1.234.567');
  });

  test('formatea fechas en formato dd/mm/aaaa', () {
    expect(formatearFecha(null), '');
    expect(formatearFecha(DateTime(2026, 11, 7)), '07/11/2026');
  });
}
