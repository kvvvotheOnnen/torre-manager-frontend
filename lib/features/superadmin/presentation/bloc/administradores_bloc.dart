// ignore_for_file: prefer_initializing_formals
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/administrador.dart';
import '../../domain/usecases/crear_administrador_usecase.dart';
import '../../domain/usecases/listar_administradores_usecase.dart';

sealed class AdministradoresEvent extends Equatable {
  const AdministradoresEvent();

  @override
  List<Object?> get props => [];
}

class AdministradoresSolicitados extends AdministradoresEvent {
  const AdministradoresSolicitados();
}

class AdministradorCreado extends AdministradoresEvent {
  const AdministradorCreado({
    required this.nombre,
    required this.correo,
    required this.password,
  });

  final String nombre;
  final String correo;
  final String password;

  @override
  List<Object?> get props => [nombre, correo, password];
}

class AdministradoresMensajeConsumido extends AdministradoresEvent {
  const AdministradoresMensajeConsumido();
}

class AdministradoresState extends Equatable {
  const AdministradoresState({
    this.cargando = false,
    this.guardando = false,
    this.administradores = const [],
    this.mensaje,
    this.exito = false,
  });

  final bool cargando;
  final bool guardando;
  final List<Administrador> administradores;
  final String? mensaje;
  final bool exito;

  AdministradoresState copyWith({
    bool? cargando,
    bool? guardando,
    List<Administrador>? administradores,
    String? mensaje,
    bool? exito,
    bool limpiarMensaje = false,
  }) {
    return AdministradoresState(
      cargando: cargando ?? this.cargando,
      guardando: guardando ?? this.guardando,
      administradores: administradores ?? this.administradores,
      mensaje: limpiarMensaje ? null : (mensaje ?? this.mensaje),
      exito: limpiarMensaje ? false : (exito ?? this.exito),
    );
  }

  @override
  List<Object?> get props => [
    cargando,
    guardando,
    administradores,
    mensaje,
    exito,
  ];
}

class AdministradoresBloc
    extends Bloc<AdministradoresEvent, AdministradoresState> {
  AdministradoresBloc({
    required ListarAdministradoresUseCase listarAdministradoresUseCase,
    required CrearAdministradorUseCase crearAdministradorUseCase,
  }) : _listarAdministradoresUseCase = listarAdministradoresUseCase,
       _crearAdministradorUseCase = crearAdministradorUseCase,
       super(const AdministradoresState()) {
    on<AdministradoresSolicitados>(_onSolicitados);
    on<AdministradorCreado>(_onCreado);
    on<AdministradoresMensajeConsumido>(_onMensajeConsumido);
  }

  final ListarAdministradoresUseCase _listarAdministradoresUseCase;
  final CrearAdministradorUseCase _crearAdministradorUseCase;

  Future<void> _onSolicitados(
    AdministradoresSolicitados event,
    Emitter<AdministradoresState> emit,
  ) async {
    emit(state.copyWith(cargando: true, limpiarMensaje: true));

    final result = await _listarAdministradoresUseCase();

    result.fold(
      (failure) =>
          emit(state.copyWith(cargando: false, mensaje: failure.message)),
      (administradores) => emit(
        state.copyWith(
          cargando: false,
          administradores: administradores,
          limpiarMensaje: true,
        ),
      ),
    );
  }

  Future<void> _onCreado(
    AdministradorCreado event,
    Emitter<AdministradoresState> emit,
  ) async {
    emit(state.copyWith(guardando: true, limpiarMensaje: true));

    final result = await _crearAdministradorUseCase(
      nombre: event.nombre,
      correo: event.correo,
      password: event.password,
    );

    await result.fold(
      (failure) async =>
          emit(state.copyWith(guardando: false, mensaje: failure.message)),
      (administrador) async {
        emit(
          state.copyWith(
            guardando: false,
            administradores: [...state.administradores, administrador],
            mensaje: 'Administrador registrado.',
            exito: true,
          ),
        );
        add(const AdministradoresMensajeConsumido());
      },
    );
  }

  void _onMensajeConsumido(
    AdministradoresMensajeConsumido event,
    Emitter<AdministradoresState> emit,
  ) {
    emit(state.copyWith(limpiarMensaje: true));
  }
}
