// ignore_for_file: prefer_initializing_formals
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/tipo_servicio.dart';
import '../../domain/entities/trabajador_servicio.dart';
import '../../domain/entities/trabajador_servicio_foto.dart';
import '../../domain/usecases/actualizar_trabajador_usecase.dart';
import '../../domain/usecases/crear_trabajador_usecase.dart';
import '../../domain/usecases/eliminar_trabajador_usecase.dart';
import '../../domain/usecases/listar_trabajadores_usecase.dart';

const _acentos = <String, String>{
  'á': 'a',
  'é': 'e',
  'í': 'i',
  'ó': 'o',
  'ú': 'u',
  'ü': 'u',
  'ñ': 'n',
};

/// Normaliza texto para comparar sin distinguir mayúsculas ni tildes.
String _normalizar(String texto) {
  final buffer = StringBuffer();

  for (final rune in texto.toLowerCase().runes) {
    final caracter = String.fromCharCode(rune);
    buffer.write(_acentos[caracter] ?? caracter);
  }

  return buffer.toString();
}

sealed class ServiciosEvent {
  const ServiciosEvent();
}

final class ServiciosSolicitados extends ServiciosEvent {
  const ServiciosSolicitados();
}

final class FiltroServicioCambiado extends ServiciosEvent {
  const FiltroServicioCambiado(this.tipo);

  final TipoServicio? tipo;
}

final class BusquedaServiciosCambiada extends ServiciosEvent {
  const BusquedaServiciosCambiada(this.texto);

  final String texto;
}

final class TrabajadorGuardado extends ServiciosEvent {
  const TrabajadorGuardado({
    this.id,
    required this.nombre,
    this.nombreEmpresa,
    required this.telefono,
    required this.tipo,
    this.descripcion,
    this.foto,
  });

  final String? id;
  final String nombre;
  final String? nombreEmpresa;
  final String telefono;
  final TipoServicio tipo;
  final String? descripcion;
  final TrabajadorServicioFoto? foto;
}

final class TrabajadorEliminadoSolicitado extends ServiciosEvent {
  const TrabajadorEliminadoSolicitado(this.id);

  final String id;
}

final class MensajeServiciosConsumido extends ServiciosEvent {
  const MensajeServiciosConsumido();
}

enum ServiciosStatus { inicial, cargando, cargado, error }

class ServiciosState extends Equatable {
  const ServiciosState({
    this.status = ServiciosStatus.inicial,
    this.trabajadores = const [],
    this.tipo,
    this.busqueda = '',
    this.mensaje,
    this.guardando = false,
  });

  final ServiciosStatus status;
  final List<TrabajadorServicio> trabajadores;
  final TipoServicio? tipo;
  final String busqueda;
  final String? mensaje;
  final bool guardando;

  bool get cargando => status == ServiciosStatus.cargando;
  bool get tieneError => status == ServiciosStatus.error;

  /// Trabajadores que cumplen el tipo y el texto de búsqueda.
  ///
  /// El filtrado es local para que los chips y el buscador respondan al
  /// instante: la lista completa se pide una sola vez al backend.
  List<TrabajadorServicio> get trabajadoresVisibles {
    final termino = _normalizar(busqueda.trim());

    return trabajadores.where((trabajador) {
      if (tipo != null && trabajador.tipo != tipo) {
        return false;
      }

      if (termino.isEmpty) {
        return true;
      }

      final texto = _normalizar(
        [
          trabajador.nombre,
          trabajador.nombreEmpresa ?? '',
          trabajador.descripcion ?? '',
          trabajador.tipo.etiqueta,
          trabajador.telefono,
        ].join(' '),
      );

      return texto.contains(termino);
    }).toList(growable: false);
  }

  bool get sinResultados =>
      status == ServiciosStatus.cargado && trabajadoresVisibles.isEmpty;

  ServiciosState copyWith({
    ServiciosStatus? status,
    List<TrabajadorServicio>? trabajadores,
    TipoServicio? tipo,
    bool limpiarTipo = false,
    String? busqueda,
    String? mensaje,
    bool limpiarMensaje = false,
    bool? guardando,
  }) {
    return ServiciosState(
      status: status ?? this.status,
      trabajadores: trabajadores ?? this.trabajadores,
      tipo: limpiarTipo ? null : (tipo ?? this.tipo),
      busqueda: busqueda ?? this.busqueda,
      mensaje: limpiarMensaje ? null : (mensaje ?? this.mensaje),
      guardando: guardando ?? this.guardando,
    );
  }

  @override
  List<Object?> get props => [
    status,
    trabajadores,
    tipo,
    busqueda,
    mensaje,
    guardando,
  ];
}

class ServiciosBloc extends Bloc<ServiciosEvent, ServiciosState> {
  ServiciosBloc({
    required ListarTrabajadoresUseCase listar,
    required CrearTrabajadorUseCase crear,
    required ActualizarTrabajadorUseCase actualizar,
    required EliminarTrabajadorUseCase eliminar,
  }) : _listar = listar,
       _crear = crear,
       _actualizar = actualizar,
       _eliminar = eliminar,
       super(const ServiciosState()) {
    on<ServiciosSolicitados>(_cargar);
    on<FiltroServicioCambiado>(_cambiarFiltro);
    on<BusquedaServiciosCambiada>(_cambiarBusqueda);
    on<TrabajadorGuardado>(_guardar);
    on<TrabajadorEliminadoSolicitado>(_borrar);
    on<MensajeServiciosConsumido>(
      (event, emit) => emit(state.copyWith(limpiarMensaje: true)),
    );
  }

  final ListarTrabajadoresUseCase _listar;
  final CrearTrabajadorUseCase _crear;
  final ActualizarTrabajadorUseCase _actualizar;
  final EliminarTrabajadorUseCase _eliminar;

  Future<void> _cargar(
    ServiciosSolicitados event,
    Emitter<ServiciosState> emit,
  ) async {
    emit(state.copyWith(status: ServiciosStatus.cargando));
    final resultado = await _listar(tipo: state.tipo, buscar: state.busqueda);
    resultado.fold(
      (failure) => emit(
        state.copyWith(
          status: ServiciosStatus.error,
          mensaje: failure.message,
        ),
      ),
      (trabajadores) => emit(
        state.copyWith(
          status: ServiciosStatus.cargado,
          trabajadores: trabajadores,
        ),
      ),
    );
  }

  void _cambiarFiltro(
    FiltroServicioCambiado event,
    Emitter<ServiciosState> emit,
  ) {
    emit(
      state.copyWith(tipo: event.tipo, limpiarTipo: event.tipo == null),
    );
  }

  void _cambiarBusqueda(
    BusquedaServiciosCambiada event,
    Emitter<ServiciosState> emit,
  ) {
    emit(state.copyWith(busqueda: event.texto));
  }

  Future<void> _guardar(
    TrabajadorGuardado event,
    Emitter<ServiciosState> emit,
  ) async {
    emit(state.copyWith(guardando: true, limpiarMensaje: true));

    final resultado = event.id == null
        ? await _crear(
            nombre: event.nombre,
            nombreEmpresa: event.nombreEmpresa,
            telefono: event.telefono,
            tipo: event.tipo,
            descripcion: event.descripcion,
            foto: event.foto,
          )
        : await _actualizar(
            id: event.id!,
            nombre: event.nombre,
            nombreEmpresa: event.nombreEmpresa,
            telefono: event.telefono,
            tipo: event.tipo,
            descripcion: event.descripcion,
            foto: event.foto,
          );

    resultado.fold(
      (failure) => emit(
        state.copyWith(guardando: false, mensaje: failure.message),
      ),
      (trabajador) {
        emit(
          state.copyWith(
            guardando: false,
            mensaje: event.id == null
                ? 'Trabajador agregado.'
                : 'Trabajador actualizado.',
          ),
        );
        add(const ServiciosSolicitados());
      },
    );
  }

  Future<void> _borrar(
    TrabajadorEliminadoSolicitado event,
    Emitter<ServiciosState> emit,
  ) async {
    final resultado = await _eliminar(event.id);
    resultado.fold(
      (failure) => emit(state.copyWith(mensaje: failure.message)),
      (_) {
        emit(state.copyWith(mensaje: 'Trabajador eliminado.'));
        add(const ServiciosSolicitados());
      },
    );
  }
}
