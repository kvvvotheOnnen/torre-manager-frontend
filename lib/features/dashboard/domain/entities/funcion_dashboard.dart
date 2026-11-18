import 'package:equatable/equatable.dart';

/// Alcance sobre el que opera una función del dashboard.
enum AmbitoFuncion { proyecto, unidad, propio }

/// Interpreta el ámbito sin romper si el backend envía un valor desconocido.
AmbitoFuncion ambitoFuncionDesde(String valor) {
  return switch (valor) {
    'unidad' => AmbitoFuncion.unidad,
    'propio' => AmbitoFuncion.propio,
    _ => AmbitoFuncion.proyecto,
  };
}

/// Función de negocio que el usuario puede ejecutar en el proyecto activo.
///
/// Entidad pura: no conoce JSON, HTTP ni roles. El cómo se autoriza quedó
/// resuelto en el backend antes de llegar aquí.
class FuncionDashboard extends Equatable {
  const FuncionDashboard({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.capacidades,
    required this.ambito,
    required this.ruta,
    this.acciones = const <String, bool>{},
  });

  final String id;
  final String titulo;
  final String descripcion;
  final String icono;
  final List<String> capacidades;
  final AmbitoFuncion ambito;
  final String ruta;

  /// Acciones ya autorizadas por el backend para este usuario.
  /// El cliente las usa para mostrar u ocultar botones, nunca para decidir.
  final Map<String, bool> acciones;

  bool get esDeProyecto => ambito == AmbitoFuncion.proyecto;
  bool get esDeUnidad => ambito == AmbitoFuncion.unidad;
  bool get esPropia => ambito == AmbitoFuncion.propio;

  bool puede(String accion) => acciones[accion] == true;

  @override
  List<Object> get props => [
    id,
    titulo,
    descripcion,
    icono,
    capacidades.join('|'),
    ambito,
    ruta,
    acciones.entries.map((entrada) => '${entrada.key}=${entrada.value}').join('|'),
  ];
}
