import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/features/paqueteria/data/models/paquete_dto.dart';

void main() {
  group('PaqueteDto', () {
    test(
      'lee el nombre de quien retiró el paquete y lo mapea a la entidad',
      () {
        final dto = PaqueteDto.fromJson({
          'id': 12,
          'descripcion': 'Sobre',
          'estado': 'retirado',
          'fecha_recepcion': '2026-11-08 10:00:00',
          'retirado_por_nombre': 'Nombre Apellido',
          'proyecto_id': 7,
          'unidad_principal_id': 42,
        });

        expect(dto.retiradoPorNombre, 'Nombre Apellido');
        expect(dto.toEntity().retiradoPorNombre, 'Nombre Apellido');
        expect(dto.toEntity().proyectoId, '7');
        expect(dto.toEntity().unidadPrincipalId, '42');
      },
    );

    test('acepta paquetes históricos sin nombre de quien retiró', () {
      final dto = PaqueteDto.fromJson({
        'id': 13,
        'descripcion': 'Paquete histórico',
        'estado': 'retirado',
        'fecha_recepcion': '2026-11-01 10:00:00',
      });

      expect(dto.toEntity().retiradoPorNombre, isNull);
    });
  });
}
