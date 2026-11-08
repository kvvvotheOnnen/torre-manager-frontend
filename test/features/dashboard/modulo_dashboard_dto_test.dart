import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/features/dashboard/data/models/modulo_dashboard_dto.dart';
import 'package:torre_manager_frontend/features/dashboard/domain/entities/modulo_dashboard.dart';

void main() {
  group('ModuloDashboardDTO', () {
    test('parsea un módulo general habilitado', () {
      final dto = ModuloDashboardDTO.fromJson({
        'id': 'registro_conserjes',
        'nombre': 'Registro de conserjes',
        'descripcion': 'Gestiona conserjes',
        'tipo': 'general',
        'habilitado': true,
      });
      final entity = dto.toEntity();

      expect(entity.id, 'registro_conserjes');
      expect(entity.tipo, TipoModuloDashboard.general);
      expect(entity.esGeneral, isTrue);
      expect(entity.habilitado, isTrue);
    });

    test('parsea un módulo de proyecto deshabilitado', () {
      final dto = ModuloDashboardDTO.fromJson({
        'id': 'paqueteria',
        'nombre': 'Paquetería',
        'descripcion': 'Encomiendas',
        'tipo': 'proyecto',
        'habilitado': false,
      });
      final entity = dto.toEntity();

      expect(entity.tipo, TipoModuloDashboard.proyecto);
      expect(entity.esGeneral, isFalse);
      expect(entity.habilitado, isFalse);
    });

    test('tolera valores ausentes y tipo desconocido', () {
      final dto = ModuloDashboardDTO.fromJson({
        'id': 'modulo_nuevo',
        'tipo': 'desconocido',
      });
      final entity = dto.toEntity();

      expect(entity.nombre, '');
      expect(entity.tipo, TipoModuloDashboard.proyecto);
      expect(entity.habilitado, isFalse);
    });
  });
}
