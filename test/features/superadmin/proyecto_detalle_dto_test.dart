import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/features/superadmin/data/models/proyecto_detalle_dto.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/entities/modulo_general.dart';
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
            'capacidad': 40,
            'descripcion': 'Espacio para reuniones',
            'atributos': atributos,
          },
        ],
        'admin_ids': [2],
      };
    }




    test('parsea el tipo de condominio edificio', () {
      final json = baseJson()..['tipo_condominio'] = 'edificio';
      final dto = ProyectoDetalleDTO.fromJson(json);

      expect(dto.toEntity().tipoCondominio, TipoCondominio.edificio);
    });

    test('parsea los módulos globales deshabilitados', () {
      final json = baseJson()
        ..['modulos_deshabilitados'] = ['paqueteria', 'desconocido'];

      final entity = ProyectoDetalleDTO.fromJson(json).toEntity();

      expect(entity.modulosDeshabilitados, [ModuloGeneral.paqueteria]);
    });

    test('tolera módulos deshabilitados ausentes', () {
      final entity = ProyectoDetalleDTO.fromJson(baseJson()).toEntity();

      expect(entity.modulosDeshabilitados, isEmpty);
    });

    test('ignora módulos que ya no son configurables', () {
      final json = baseJson()
        ..['modulos'] = ['infraestructura', 'paqueteria', 'quincho'];
      final entity = ProyectoDetalleDTO.fromJson(json).toEntity();

      expect(entity.modulos, [ModuloSistema.infraestructura]);
    });
  });
}
