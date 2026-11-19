import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/features/infraestructura/domain/entities/tipo_agrupacion.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/entities/definicion_agrupacion.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/services/generador_unidades_clasificables.dart';

void main() {
  const generador = GeneradorUnidadesClasificables();

  test('genera unidades por piso igual que el backend', () {
    final unidades = generador.paraAgrupacion(
      const DefinicionAgrupacion(
        nombre: 'Torre A',
        tipo: TipoAgrupacion.torre,
        pisoDesde: 1,
        pisoHasta: 2,
        unidadesPorPiso: 2,
      ),
    );

    expect(
      unidades.map((unidad) => unidad.identificador),
      ['Torre A-101', 'Torre A-102', 'Torre A-201', 'Torre A-202'],
    );
    expect(unidades.every((unidad) => unidad.agrupacion == 'Torre A'), isTrue);
  });

  test('respeta pisos con excepción y agrega solo unidades simples', () {
    final unidades = generador.paraAgrupacion(
      const DefinicionAgrupacion(
        nombre: 'Edificio',
        tipo: TipoAgrupacion.edificio,
        pisoDesde: 1,
        pisoHasta: 2,
        unidadesPorPiso: 2,
        pisosExcepcion: [
          PisoExcepcion(
            piso: 2,
            unidades: [
              UnidadExcepcion(
                identificador: '',
                tipo: TipoUnidadExcepcion.simple,
              ),
              UnidadExcepcion(
                identificador: 'Quincho',
                tipo: TipoUnidadExcepcion.instalacionExtra,
                capacidad: 20,
              ),
            ],
          ),
        ],
      ),
    );

    expect(
      unidades.map((unidad) => unidad.identificador),
      ['Unidad-101', 'Unidad-102', 'Unidad-201'],
    );
    expect(
      unidades.map((unidad) => unidad.identificador),
      isNot(contains('Quincho')),
    );
  });

  test('un piso con excepción vacío salta la generación automática', () {
    final unidades = generador.paraAgrupacion(
      const DefinicionAgrupacion(
        nombre: 'Edificio',
        tipo: TipoAgrupacion.edificio,
        pisoDesde: 1,
        pisoHasta: 3,
        unidadesPorPiso: 2,
        pisosExcepcion: [PisoExcepcion(piso: 2, unidades: [])],
      ),
    );

    expect(
      unidades.map((unidad) => unidad.identificador),
      ['Unidad-101', 'Unidad-102', 'Unidad-301', 'Unidad-302'],
    );
  });

  test('las manzanas usan la secuencia Casa', () {
    final unidades = generador.paraAgrupacion(
      const DefinicionAgrupacion(
        nombre: 'Manzana 1',
        tipo: TipoAgrupacion.manzana,
        cantidad: 3,
      ),
    );

    expect(
      unidades.map((unidad) => unidad.identificador),
      ['Casa 1', 'Casa 2', 'Casa 3'],
    );
  });

  test('devuelve vacío si el rango de pisos no es válido', () {
    final unidades = generador.paraAgrupacion(
      const DefinicionAgrupacion(
        nombre: 'Torre A',
        tipo: TipoAgrupacion.torre,
        pisoDesde: 3,
        pisoHasta: 1,
        unidadesPorPiso: 2,
      ),
    );

    expect(unidades, isEmpty);
  });
}
