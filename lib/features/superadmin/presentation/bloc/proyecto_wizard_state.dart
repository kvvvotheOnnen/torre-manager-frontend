import 'package:equatable/equatable.dart';

import '../../domain/entities/tipo_condominio.dart';

class ProyectoWizardState extends Equatable {
  const ProyectoWizardState({
    this.proyectoId,
    this.nombre = '',
    this.descripcion,
    this.pasoActual = 0,
    this.guardando = false,
    this.descartando = false,
    this.finalizado = false,
    this.mensaje,
    this.mensajeEsError = false,
    this.tipoConfirmado,
  });

  final String? proyectoId;
  final String nombre;
  final String? descripcion;
  final int pasoActual;
  final bool guardando;
  final bool descartando;
  final bool finalizado;
  final String? mensaje;
  final bool mensajeEsError;
  final TipoCondominio? tipoConfirmado;

  ProyectoWizardState copyWith({
    String? proyectoId,
    String? nombre,
    String? descripcion,
    int? pasoActual,
    bool? guardando,
    bool? descartando,
    bool? finalizado,
    String? mensaje,
    bool? mensajeEsError,
    TipoCondominio? tipoConfirmado,
    bool limpiarMensaje = false,
  }) {
    return ProyectoWizardState(
      proyectoId: proyectoId ?? this.proyectoId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      pasoActual: pasoActual ?? this.pasoActual,
      guardando: guardando ?? this.guardando,
      descartando: descartando ?? this.descartando,
      finalizado: finalizado ?? this.finalizado,
      mensaje: limpiarMensaje ? null : (mensaje ?? this.mensaje),
      mensajeEsError: limpiarMensaje
          ? false
          : (mensajeEsError ?? this.mensajeEsError),
      tipoConfirmado: tipoConfirmado ?? this.tipoConfirmado,
    );
  }

  @override
  List<Object?> get props => [
    proyectoId,
    nombre,
    descripcion,
    pasoActual,
    guardando,
    descartando,
    finalizado,
    mensaje,
    mensajeEsError,
    tipoConfirmado,
  ];
}
