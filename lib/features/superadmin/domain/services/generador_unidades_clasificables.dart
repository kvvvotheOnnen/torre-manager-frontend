import '../../../infraestructura/domain/entities/tipo_agrupacion.dart';
import '../entities/clasificacion_unidad.dart';
import '../entities/definicion_agrupacion.dart';

/// Calcula las unidades principales que generará una definición de estructura.
///
/// Replica la regla del backend (`GeneradorIdentificacionesUnidades` y
/// `NormalizadorEstructuraProyecto`) para poder ofrecer la clasificación en el
/// mismo paso en que se define la estructura, antes de persistirla.
class GeneradorUnidadesClasificables {
  const GeneradorUnidadesClasificables();

  static const int maxUnidades = 500;

  List<UnidadClasificable> paraDefiniciones(
    List<DefinicionAgrupacion> agrupaciones,
  ) {
    return agrupaciones
        .expand(paraAgrupacion)
        .toList(growable: false);
  }

  List<UnidadClasificable> paraAgrupacion(DefinicionAgrupacion agrupacion) {
    final nombre = agrupacion.nombre.trim();
    if (nombre.isEmpty) return const [];

    final prefijo = (agrupacion.prefijo ?? '').trim();

    if (agrupacion.tipo == TipoAgrupacion.manzana) {
      final cantidad = agrupacion.cantidad ?? 0;
      if (cantidad < 1) return const [];

      final base = prefijo.isEmpty ? 'Casa' : prefijo;

      return List.generate(
        cantidad,
        (index) => UnidadClasificable(
          agrupacion: nombre,
          identificador: '$base ${index + 1}',
        ),
      );
    }

    final pisoDesde = agrupacion.pisoDesde;
    final pisoHasta = agrupacion.pisoHasta;
    final unidadesPorPiso = agrupacion.unidadesPorPiso;

    if (pisoDesde == null ||
        pisoHasta == null ||
        unidadesPorPiso == null ||
        pisoHasta < pisoDesde ||
        unidadesPorPiso < 1) {
      return const [];
    }

    final base = prefijo.isEmpty ? nombre : prefijo;
    final excluidos = agrupacion.pisosExcepcion
        .where((piso) => !piso.sinUnidades)
        .map((piso) => piso.piso)
        .toSet();

    final identificadores = <String>[];

    for (var piso = pisoDesde; piso <= pisoHasta; piso++) {
      if (excluidos.contains(piso)) continue;

      for (var numero = 1; numero <= unidadesPorPiso; numero++) {
        identificadores.add(_identificador(base, piso, numero));
      }
    }

    for (final excepcion in agrupacion.pisosExcepcion) {
      if (excepcion.sinUnidades) continue;

      var secuenciaSimple = 0;

      for (final unidad in excepcion.unidades) {
        if (unidad.tipo != TipoUnidadExcepcion.simple) continue;
        secuenciaSimple++;
        identificadores.add(
          _identificador(base, excepcion.piso, secuenciaSimple),
        );
      }
    }

    if (identificadores.length > maxUnidades) return const [];

    return identificadores
        .map(
          (identificador) => UnidadClasificable(
            agrupacion: nombre,
            identificador: identificador,
          ),
        )
        .toList(growable: false);
  }

  String _identificador(String prefijo, int piso, int numero) {
    final base = prefijo.isEmpty ? '' : '$prefijo-';
    return '$base$piso${numero.toString().padLeft(2, '0')}';
  }
}
