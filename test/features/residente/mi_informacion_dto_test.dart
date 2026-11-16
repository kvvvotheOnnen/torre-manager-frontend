import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/features/residente/data/models/mi_informacion_dto.dart';

void main() {
  test('parsea múltiples unidades y mantiene compatibilidad', () {
    final dto = MiInformacionDto.fromJson({
      'unidad': '801',
      'agrupacion': 'Edificio',
      'unidades': [
        {
          'unidad': '801',
          'agrupacion': 'Edificio',
          'proyecto_id': 1,
          'tipo_vinculo': 'propietario',
          'es_actual': true,
          'fecha_inicio': '2026-01-01',
        },
        {
          'unidad': '802',
          'agrupacion': 'Edificio',
          'proyecto_id': 1,
          'tipo_vinculo': 'arrendatario',
          'es_actual': false,
          'fecha_inicio': '2025-01-01',
          'fecha_fin': '2025-12-31',
        },
      ],
    });

    expect(dto.unidades.length, 2);
    expect(dto.unidades.first.tipoVinculo, 'propietario');
    expect(dto.unidades.first.esActual, true);
    expect(dto.unidades.last.fechaFin, '2025-12-31');
  });

  test('usa la respuesta antigua cuando no hay lista de unidades', () {
    final dto = MiInformacionDto.fromJson({
      'unidad': '801',
      'agrupacion': 'Edificio',
    });

    expect(dto.unidades.single.unidad, '801');
    expect(dto.unidades.single.agrupacion, 'Edificio');
    expect(dto.unidades.single.esActual, true);
  });
}
