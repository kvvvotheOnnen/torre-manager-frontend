part of 'infraestructura_bloc.dart';

sealed class InfraestructuraEvent {
  const InfraestructuraEvent();
}

/// Inicia el módulo: resuelve el proyecto del usuario y carga el árbol.
class InfraestructuraIniciado extends InfraestructuraEvent {
  const InfraestructuraIniciado();
}

class InfraestructuraArbolSolicitado extends InfraestructuraEvent {
  const InfraestructuraArbolSolicitado({required this.proyectoId});

  final String proyectoId;
}

class InfraestructuraAgrupacionRegistrada extends InfraestructuraEvent {
  const InfraestructuraAgrupacionRegistrada({
    required this.proyectoId,
    required this.nombre,
    required this.tipo,
    this.prefijo,
    required this.pisoDesde,
    required this.pisoHasta,
    required this.unidadesPorPiso,
  });

  final String proyectoId;
  final String nombre;
  final TipoAgrupacion tipo;
  final String? prefijo;
  final int pisoDesde;
  final int pisoHasta;
  final int unidadesPorPiso;
}

class InfraestructuraUnidadAccesoriaCreada extends InfraestructuraEvent {
  const InfraestructuraUnidadAccesoriaCreada({
    required this.proyectoId,
    required this.identificador,
    required this.tipo,
    this.unidadPrincipalId,
  });

  final String proyectoId;
  final String identificador;
  final TipoUnidadAccesoria tipo;
  final String? unidadPrincipalId;
}

class InfraestructuraAccesoriaAsignada extends InfraestructuraEvent {
  const InfraestructuraAccesoriaAsignada({
    required this.proyectoId,
    required this.unidadAccesoriaId,
    this.unidadPrincipalId,
  });

  final String proyectoId;
  final String unidadAccesoriaId;
  final String? unidadPrincipalId;
}

class InfraestructuraMensajeConsumido extends InfraestructuraEvent {
  const InfraestructuraMensajeConsumido();
}
