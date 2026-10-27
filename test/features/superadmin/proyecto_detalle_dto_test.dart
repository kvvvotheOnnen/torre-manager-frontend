import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/features/superadmin/data/models/proyecto_detalle_dto.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/entities/modulo_sistema.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/entities/tipo_condominio.dart';

void main() {
  group('ProyectoDetalleDTO', () {
    Map<String, dynamic> baseJson({
      Object? atributos = const <String, dynamic>{},
    }) {
      return {
        'id': 3,
        'nombre': 'Test',
        'descripcion': null,
        'tipo_condominio': 'torres',
        'modulos': ['infraestructura'],
        'instalaciones_extra': [
          {
            'id': 1,
            'nombre': 'Quincho',
            'tipo': 'quincho',
            'atributos': atributos,
          },
        ],
        'admin_ids': [2],
      };
    }

    test('parsea atributos como mapa', () {
      final dto = ProyectoDetalleDTO.fromJson(
        baseJson(atributos: {'largo_m': 12}),
      );
      final entity = dto.toEntity();

      expect(entity.tipoCondominio, TipoCondominio.torres);
      expect(entity.modulos, [ModuloSistema.infraestructura]);
      expect(entity.instalacionesExtra.single.atributos, {'largo_m': 12});
    });

    test('tolera atributos como lista vacía (JSON [])', () {
      final dto = ProyectoDetalleDTO.fromJson(baseJson(atributos: <Object>[]));
      final entity = dto.toEntity();

      expect(entity.instalacionesExtra.single.atributos, isEmpty);
    });

    test('tolera atributos ausentes/null', () {
      final dto = ProyectoDetalleDTO.fromJson(baseJson(atributos: null));
      final entity = dto.toEntity();

      expect(entity.instalacionesExtra.single.atributos, isEmpty);
    });

    test('parsea el tipo de condominio edificio', () {
      final json = baseJson()..['tipo_condominio'] = 'edificio';
      final dto = ProyectoDetalleDTO.fromJson(json);

      expect(dto.toEntity().tipoCondominio, TipoCondominio.edificio);
    });
  });
}
