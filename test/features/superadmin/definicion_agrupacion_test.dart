import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/entities/definicion_agrupacion.dart';

void main() {
  group('instalacionesDePisosExcepcion', () {
    test('extrae solo las unidades marcadas como instalación extra', () {
      const pisos = [
        PisoExcepcion(
          piso: 7,
          unidades: [
            UnidadExcepcion(
              identificador: 'PH',
              tipo: TipoUnidadExcepcion.simple,
            ),
            UnidadExcepcion(
              identificador: 'Quincho',
              tipo: TipoUnidadExcepcion.instalacionExtra,
              capacidad: 80,
              descripcion: 'Sala de fiestas',
            ),
          ],
        ),
        PisoExcepcion(
          piso: 8,
          unidades: [
            UnidadExcepcion(
              identificador: 'Gimnasio',
              tipo: TipoUnidadExcepcion.instalacionExtra,
              capacidad: 30,
            ),
          ],
        ),
      ];

      final instalaciones = instalacionesDePisosExcepcion(pisos);

      expect(instalaciones, hasLength(2));
      expect(instalaciones[0].nombre, 'Quincho');
      expect(instalaciones[0].capacidad, 80);
      expect(instalaciones[0].descripcion, 'Sala de fiestas');
      expect(instalaciones[1].nombre, 'Gimnasio');
      expect(instalaciones[1].capacidad, 30);
      expect(instalaciones[1].descripcion, isNull);
    });

    test('retorna vacío si no hay instalaciones extra', () {
      const pisos = [
        PisoExcepcion(
          piso: 1,
          unidades: [
            UnidadExcepcion(
              identificador: '101',
              tipo: TipoUnidadExcepcion.simple,
            ),
          ],
        ),
      ];

      expect(instalacionesDePisosExcepcion(pisos), isEmpty);
    });
  });
}
