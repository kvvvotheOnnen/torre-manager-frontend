import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/features/servicios/data/models/trabajador_servicio_dto.dart';
import 'package:torre_manager_frontend/features/servicios/domain/entities/tipo_servicio.dart';

void main() {
  group('TrabajadorServicioDto', () {
    test('mapea todos los campos del backend', () {
      final dto = TrabajadorServicioDto.fromJson(const {
        'id': 7,
        'nombre': 'Andrés Pérez',
        'nombre_empresa': 'Electricidad Pérez',
        'telefono': '+56912345678',
        'tipo_servicio': 'electricista',
        'tipo_etiqueta': 'Electricista',
        'descripcion': 'Instalaciones y emergencias.',
        'foto_url': 'http://localhost/storage/servicios/1/foto.jpg',
      });

      expect(dto.id, '7');
      expect(dto.nombre, 'Andrés Pérez');
      expect(dto.nombreEmpresa, 'Electricidad Pérez');
      expect(dto.telefono, '+56912345678');
      expect(dto.tipo, TipoServicio.electricista);
      expect(dto.descripcion, 'Instalaciones y emergencias.');
      expect(dto.fotoUrl, 'http://localhost/storage/servicios/1/foto.jpg');
      expect(dto.toEntity().tieneFoto, isTrue);
    });

    test('usa Otro cuando el tipo no se reconoce', () {
      final dto = TrabajadorServicioDto.fromJson(const {
        'id': 1,
        'nombre': 'Sin tipo',
        'telefono': '123',
        'tipo_servicio': 'jardinero',
      });

      expect(dto.tipo, TipoServicio.otro);
    });

    test('normaliza campos opcionales vacíos y sin foto', () {
      final dto = TrabajadorServicioDto.fromJson(const {
        'id': 2,
        'nombre': 'María',
        'nombre_empresa': '   ',
        'telefono': '999',
        'tipo_servicio': 'gasfiter',
        'descripcion': '',
        'foto_url': null,
      });

      final entidad = dto.toEntity();

      expect(entidad.nombreEmpresa, isNull);
      expect(entidad.descripcion, isNull);
      expect(entidad.fotoUrl, isNull);
      expect(entidad.tieneFoto, isFalse);
      expect(entidad.tipo, TipoServicio.gasfiter);
    });
  });
}
