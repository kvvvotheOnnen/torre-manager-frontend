part of 'infraestructura_bloc.dart';

enum InfraestructuraStatus { inicial, cargando, guardando, cargado, error }

class InfraestructuraState extends Equatable {
  const InfraestructuraState({
    this.status = InfraestructuraStatus.inicial,
    this.arbol,
    this.mensaje,
  });

  final InfraestructuraStatus status;
  final ArbolInfraestructura? arbol;
  final String? mensaje;

  bool get tieneCarga => status == InfraestructuraStatus.cargando || status == InfraestructuraStatus.guardando;

  InfraestructuraState copyWith({
    InfraestructuraStatus? status,
    ArbolInfraestructura? arbol,
    String? mensaje,
    bool limpiarMensaje = false,
  }) {
    return InfraestructuraState(
      status: status ?? this.status,
      arbol: arbol ?? this.arbol,
      mensaje: limpiarMensaje ? null : (mensaje ?? this.mensaje),
    );
  }

  @override
  List<Object?> get props => [status, arbol, mensaje];
}
