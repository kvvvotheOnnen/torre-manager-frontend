import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/features/dashboard/data/models/funcion_dashboard_dto.dart';
import 'package:torre_manager_frontend/features/dashboard/domain/entities/funcion_dashboard.dart';

void main() {
  group('FuncionDashboardDto', () {
    test('parsea la respuesta del backend y mapea el ámbito', () {
      final dto = FuncionDashboardDto.fromJson(const {
        'id': 'control_acceso.bitacora',
        'titulo': 'Control de acceso',
        'descripcion': 'Entradas y salidas',
        'icono': 'badge',
        'capacidades': ['control_acceso.bitacora'],
        'ambito': 'unidad',
        'ruta': '/control-acceso',
      });

      final entidad = dto.toEntity();

      expect(entidad.id, 'control_acceso.bitacora');
      expect(entidad.titulo, 'Control de acceso');
      expect(entidad.capacidades, ['control_acceso.bitacora']);
      expect(entidad.ambito, AmbitoFuncion.unidad);
      expect(entidad.esDeUnidad, isTrue);
      expect(entidad.ruta, '/control-acceso');
    });

    test('tolera campos ausentes y capacidades mal formadas', () {
      final dto = FuncionDashboardDto.fromJson(const {
        'id': 'x',
        'capacidades': {'no': 'es lista'},
      });

      final entidad = dto.toEntity();

      expect(entidad.titulo, '');
      expect(entidad.capacidades, isEmpty);
      expect(entidad.ambito, AmbitoFuncion.proyecto);
      expect(entidad.esDeProyecto, isTrue);
    });

    test('un ámbito desconocido cae en proyecto', () {
      expect(ambitoFuncionDesde('departamento'), AmbitoFuncion.proyecto);
      expect(ambitoFuncionDesde('propio'), AmbitoFuncion.propio);
    });

    test('mapea las acciones resueltas y las expone con puede()', () {
      final dto = FuncionDashboardDto.fromJson(const {
        'id': 'servicios_recomendados',
        'acciones': {'gestionar': true, 'exportar': false},
      });

      final entidad = dto.toEntity();

      expect(entidad.acciones, {'gestionar': true, 'exportar': false});
      expect(entidad.puede('gestionar'), isTrue);
      expect(entidad.puede('exportar'), isFalse);
      expect(entidad.puede('inexistente'), isFalse);
    });

    test('tolera acciones ausentes o mal formadas', () {
      expect(FuncionDashboardDto.fromJson(const {'id': 'x'}).toEntity().acciones, isEmpty);
      expect(
        FuncionDashboardDto.fromJson(const {'id': 'x', 'acciones': 'no-es-mapa'})
            .toEntity()
            .puede('gestionar'),
        isFalse,
      );
    });
  });
}
