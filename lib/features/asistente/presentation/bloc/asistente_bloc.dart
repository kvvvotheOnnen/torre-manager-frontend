import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/fuente_asistente.dart';
import '../../domain/usecases/consultar_asistente_use_case.dart';

class MensajeAsistente extends Equatable {
  const MensajeAsistente({
    required this.texto,
    required this.esUsuario,
    this.fuentes = const [],
  });

  final String texto;
  final bool esUsuario;
  final List<FuenteAsistente> fuentes;

  @override
  List<Object?> get props => [texto, esUsuario, fuentes];
}

sealed class AsistenteEvent extends Equatable {
  const AsistenteEvent();

  @override
  List<Object?> get props => [];
}

class AsistentePreguntaEnviada extends AsistenteEvent {
  const AsistentePreguntaEnviada(this.pregunta);

  final String pregunta;

  @override
  List<Object?> get props => [pregunta];
}

enum AsistenteStatus { inicial, enviando, respondido, error }

class AsistenteState extends Equatable {
  const AsistenteState({
    this.status = AsistenteStatus.inicial,
    this.mensajes = const [],
    this.mensajeError,
  });

  final AsistenteStatus status;
  final List<MensajeAsistente> mensajes;
  final String? mensajeError;

  @override
  List<Object?> get props => [status, mensajes, mensajeError];
}

class AsistenteBloc extends Bloc<AsistenteEvent, AsistenteState> {
  AsistenteBloc({required this._consultarUseCase})
      : super(const AsistenteState()) {
    on<AsistentePreguntaEnviada>(_onPreguntaEnviada);
  }

  final ConsultarAsistenteUseCase _consultarUseCase;

  Future<void> _onPreguntaEnviada(
    AsistentePreguntaEnviada event,
    Emitter<AsistenteState> emit,
  ) async {
    final pregunta = event.pregunta.trim();
    if (pregunta.isEmpty) return;

    final mensajes = [
      ...state.mensajes,
      MensajeAsistente(texto: pregunta, esUsuario: true),
    ];

    emit(AsistenteState(status: AsistenteStatus.enviando, mensajes: mensajes));

    final result = await _consultarUseCase(pregunta);

    result.fold(
      (failure) => emit(
        AsistenteState(
          status: AsistenteStatus.error,
          mensajes: mensajes,
          mensajeError: failure.message,
        ),
      ),
      (respuesta) => emit(
        AsistenteState(
          status: AsistenteStatus.respondido,
          mensajes: [
            ...mensajes,
            MensajeAsistente(
              texto: respuesta.respuesta,
              esUsuario: false,
              fuentes: respuesta.fuentes,
            ),
          ],
        ),
      ),
    );
  }
}
