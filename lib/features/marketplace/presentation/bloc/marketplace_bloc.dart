// ignore_for_file: prefer_initializing_formals
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/categoria_producto.dart';
import '../../domain/entities/condicion_producto.dart';
import '../../domain/entities/estado_publicacion.dart';
import '../../domain/entities/publicacion_foto.dart';
import '../../domain/entities/publicacion_marketplace.dart';
import '../../domain/usecases/actualizar_publicacion_usecase.dart';
import '../../domain/usecases/alternar_favorito_usecase.dart';
import '../../domain/usecases/aprobar_solicitud_usecase.dart';
import '../../domain/usecases/crear_publicacion_usecase.dart';
import '../../domain/usecases/eliminar_publicacion_usecase.dart';
import '../../domain/usecases/listar_favoritos_marketplace_usecase.dart';
import '../../domain/usecases/listar_historial_marketplace_usecase.dart';
import '../../domain/usecases/listar_mis_publicaciones_usecase.dart';
import '../../domain/usecases/listar_publicaciones_usecase.dart';
import '../../domain/usecases/listar_solicitudes_usecase.dart';
import '../../domain/usecases/marcar_publicacion_vendida_usecase.dart';
import '../../domain/usecases/rechazar_solicitud_usecase.dart';
import '../../domain/usecases/retirar_publicacion_usecase.dart';

const _acentos = <String, String>{
  'á': 'a',
  'é': 'e',
  'í': 'i',
  'ó': 'o',
  'ú': 'u',
  'ü': 'u',
  'ñ': 'n',
};

String _normalizar(String texto) {
  final buffer = StringBuffer();

  for (final rune in texto.toLowerCase().runes) {
    final caracter = String.fromCharCode(rune);
    buffer.write(_acentos[caracter] ?? caracter);
  }

  return buffer.toString();
}

enum MarketplaceVista {
  catalogo,
  mias,
  favoritos,
  historial,
  eliminadas,
  solicitudes,
}

sealed class MarketplaceEvent {
  const MarketplaceEvent();
}

final class MarketplaceSolicitadas extends MarketplaceEvent {
  const MarketplaceSolicitadas({this.todas});

  final bool? todas;
}

final class VistaMarketplaceCambiada extends MarketplaceEvent {
  const VistaMarketplaceCambiada(this.vista, {this.todas});

  final MarketplaceVista vista;
  final bool? todas;
}

final class FiltroCategoriaCambiado extends MarketplaceEvent {
  const FiltroCategoriaCambiado(this.categoria);

  final CategoriaProducto? categoria;
}

final class BusquedaMarketplaceCambiada extends MarketplaceEvent {
  const BusquedaMarketplaceCambiada(this.texto);

  final String texto;
}

final class FiltroTodasCambiado extends MarketplaceEvent {
  const FiltroTodasCambiado(this.todas);

  final bool todas;
}

final class PublicacionGuardada extends MarketplaceEvent {
  const PublicacionGuardada({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.precio,
    required this.categoria,
    required this.condicion,
    this.foto,
  });

  final String? id;
  final String titulo;
  final String descripcion;
  final int precio;
  final CategoriaProducto categoria;
  final CondicionProducto condicion;
  final PublicacionFoto? foto;
}

final class PublicacionRetiradaSolicitada extends MarketplaceEvent {
  const PublicacionRetiradaSolicitada(this.id);

  final String id;
}

final class PublicacionVendidaSolicitada extends MarketplaceEvent {
  const PublicacionVendidaSolicitada(this.id);

  final String id;
}

final class PublicacionEliminadaSolicitada extends MarketplaceEvent {
  const PublicacionEliminadaSolicitada({
    required this.id,
    required this.motivo,
  });

  final String id;
  final String motivo;
}

final class FavoritoMarketplaceAlternado extends MarketplaceEvent {
  const FavoritoMarketplaceAlternado({
    required this.id,
    required this.favorito,
  });

  final String id;
  final bool favorito;
}

final class SolicitudAprobadaSolicitada extends MarketplaceEvent {
  const SolicitudAprobadaSolicitada(this.id);

  final String id;
}

final class SolicitudRechazadaSolicitada extends MarketplaceEvent {
  const SolicitudRechazadaSolicitada({required this.id, required this.motivo});

  final String id;
  final String motivo;
}

final class MensajeMarketplaceConsumido extends MarketplaceEvent {
  const MensajeMarketplaceConsumido();
}

final class ContadorSolicitudesSolicitado extends MarketplaceEvent {
  const ContadorSolicitudesSolicitado();
}

enum MarketplaceStatus { inicial, cargando, cargado, error }

class MarketplaceState extends Equatable {
  const MarketplaceState({
    this.status = MarketplaceStatus.inicial,
    this.publicaciones = const [],
    this.categoria,
    this.busqueda = '',
    this.vista = MarketplaceVista.catalogo,
    this.todas = false,
    this.mensaje,
    this.guardando = false,
    this.procesandoId,
    this.pendientes = 0,
  });

  final MarketplaceStatus status;
  final List<PublicacionMarketplace> publicaciones;
  final CategoriaProducto? categoria;
  final String busqueda;
  final MarketplaceVista vista;
  final bool todas;
  final String? mensaje;
  final bool guardando;
  final String? procesandoId;
  final int pendientes;

  bool get cargando => status == MarketplaceStatus.cargando;
  bool get tieneError => status == MarketplaceStatus.error;
  bool get ocupado => guardando || procesandoId != null;

  List<PublicacionMarketplace> get publicacionesVisibles {
    final termino = _normalizar(busqueda.trim());

    return publicaciones
        .where((publicacion) {
          if (vista == MarketplaceVista.catalogo &&
              (publicacion.esMia ||
                  publicacion.estado == EstadoPublicacion.eliminada)) {
            return false;
          }

          if (vista == MarketplaceVista.eliminadas && publicacion.esMia) {
            return false;
          }

          if (categoria != null && publicacion.categoria != categoria) {
            return false;
          }

          if (termino.isEmpty) {
            return true;
          }

          final texto = _normalizar(
            [
              publicacion.titulo,
              publicacion.descripcion,
              publicacion.categoria.etiqueta,
              publicacion.condicion.etiqueta,
            ].join(' '),
          );

          return texto.contains(termino);
        })
        .toList(growable: false);
  }

  bool get sinResultados =>
      status == MarketplaceStatus.cargado && publicacionesVisibles.isEmpty;

  MarketplaceState copyWith({
    MarketplaceStatus? status,
    List<PublicacionMarketplace>? publicaciones,
    CategoriaProducto? categoria,
    bool limpiarCategoria = false,
    String? busqueda,
    MarketplaceVista? vista,
    bool? todas,
    String? mensaje,
    bool limpiarMensaje = false,
    bool? guardando,
    String? procesandoId,
    bool limpiarProcesando = false,
    int? pendientes,
  }) {
    return MarketplaceState(
      status: status ?? this.status,
      publicaciones: publicaciones ?? this.publicaciones,
      categoria: limpiarCategoria ? null : (categoria ?? this.categoria),
      busqueda: busqueda ?? this.busqueda,
      vista: vista ?? this.vista,
      todas: todas ?? this.todas,
      mensaje: limpiarMensaje ? null : (mensaje ?? this.mensaje),
      guardando: guardando ?? this.guardando,
      procesandoId: limpiarProcesando
          ? null
          : (procesandoId ?? this.procesandoId),
      pendientes: pendientes ?? this.pendientes,
    );
  }

  @override
  List<Object?> get props => [
    status,
    publicaciones,
    categoria,
    busqueda,
    vista,
    todas,
    mensaje,
    guardando,
    procesandoId,
    pendientes,
  ];
}

class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  MarketplaceBloc({
    required ListarPublicacionesUseCase listar,
    required ListarMisPublicacionesUseCase listarMias,
    required ListarFavoritosMarketplaceUseCase listarFavoritos,
    required ListarHistorialMarketplaceUseCase listarHistorial,
    required CrearPublicacionUseCase crear,
    required ActualizarPublicacionUseCase actualizar,
    required RetirarPublicacionUseCase retirar,
    required MarcarPublicacionVendidaUseCase vender,
    required EliminarPublicacionUseCase eliminar,
    required AlternarFavoritoUseCase favorito,
    required ListarSolicitudesUseCase listarSolicitudes,
    required AprobarSolicitudMarketplaceUseCase aprobarSolicitud,
    required RechazarSolicitudMarketplaceUseCase rechazarSolicitud,
  }) : _listar = listar,
       _listarMias = listarMias,
       _listarFavoritos = listarFavoritos,
       _listarHistorial = listarHistorial,
       _crear = crear,
       _actualizar = actualizar,
       _retirar = retirar,
       _vender = vender,
       _eliminar = eliminar,
       _favorito = favorito,
       _listarSolicitudes = listarSolicitudes,
       _aprobarSolicitud = aprobarSolicitud,
       _rechazarSolicitud = rechazarSolicitud,
       super(const MarketplaceState()) {
    on<MarketplaceSolicitadas>(_cargar);
    on<VistaMarketplaceCambiada>(_cambiarVista);
    on<FiltroCategoriaCambiado>(_cambiarCategoria);
    on<BusquedaMarketplaceCambiada>(_cambiarBusqueda);
    on<FiltroTodasCambiado>(_cambiarTodas);
    on<PublicacionGuardada>(_guardar);
    on<PublicacionRetiradaSolicitada>(_retirarPublicacion);
    on<PublicacionVendidaSolicitada>(_venderPublicacion);
    on<PublicacionEliminadaSolicitada>(_eliminarPublicacion);
    on<FavoritoMarketplaceAlternado>(_alternarFavorito);
    on<SolicitudAprobadaSolicitada>(_aprobarSolicitudSolicitada);
    on<SolicitudRechazadaSolicitada>(_rechazarSolicitudSolicitada);
    on<ContadorSolicitudesSolicitado>(_cargarContadorSolicitudes);
    on<MensajeMarketplaceConsumido>(
      (event, emit) => emit(state.copyWith(limpiarMensaje: true)),
    );
  }

  final ListarPublicacionesUseCase _listar;
  final ListarMisPublicacionesUseCase _listarMias;
  final ListarFavoritosMarketplaceUseCase _listarFavoritos;
  final ListarHistorialMarketplaceUseCase _listarHistorial;
  final CrearPublicacionUseCase _crear;
  final ActualizarPublicacionUseCase _actualizar;
  final RetirarPublicacionUseCase _retirar;
  final MarcarPublicacionVendidaUseCase _vender;
  final EliminarPublicacionUseCase _eliminar;
  final AlternarFavoritoUseCase _favorito;
  final ListarSolicitudesUseCase _listarSolicitudes;
  final AprobarSolicitudMarketplaceUseCase _aprobarSolicitud;
  final RechazarSolicitudMarketplaceUseCase _rechazarSolicitud;

  Future<void> _cargar(
    MarketplaceSolicitadas event,
    Emitter<MarketplaceState> emit,
  ) async {
    final todas = event.todas ?? state.todas;
    emit(state.copyWith(status: MarketplaceStatus.cargando, todas: todas));

    if (state.vista == MarketplaceVista.solicitudes) {
      final solicitudes = await _listarSolicitudes();

      solicitudes.fold(
        (failure) => emit(
          state.copyWith(
            status: MarketplaceStatus.error,
            mensaje: failure.message,
          ),
        ),
        (resultado) => emit(
          state.copyWith(
            status: MarketplaceStatus.cargado,
            publicaciones: resultado.solicitudes,
            pendientes: resultado.pendientes,
          ),
        ),
      );
      return;
    }

    final resultado = switch (state.vista) {
      MarketplaceVista.catalogo => await _listar(todas: todas),
      MarketplaceVista.mias => await _listarMias(),
      MarketplaceVista.favoritos => await _listarFavoritos(),
      MarketplaceVista.historial => await _listarHistorial(),
      MarketplaceVista.eliminadas => await _listar(
        todas: true,
        estado: EstadoPublicacion.eliminada,
      ),
      MarketplaceVista.solicitudes => (await _listarSolicitudes()).map(
        (solicitudes) => solicitudes.solicitudes,
      ),
    };

    resultado.fold(
      (failure) => emit(
        state.copyWith(
          status: MarketplaceStatus.error,
          mensaje: failure.message,
        ),
      ),
      (publicaciones) => emit(
        state.copyWith(
          status: MarketplaceStatus.cargado,
          publicaciones: publicaciones,
        ),
      ),
    );
  }

  Future<void> _cargarContadorSolicitudes(
    ContadorSolicitudesSolicitado event,
    Emitter<MarketplaceState> emit,
  ) async {
    if (state.vista == MarketplaceVista.solicitudes) {
      return;
    }

    final solicitudes = await _listarSolicitudes();
    solicitudes.fold(
      (_) {},
      (resultado) => emit(state.copyWith(pendientes: resultado.pendientes)),
    );
  }

  void _cambiarVista(
    VistaMarketplaceCambiada event,
    Emitter<MarketplaceState> emit,
  ) {
    final todas = event.todas ?? state.todas;

    if (state.vista == event.vista &&
        (event.todas == null || event.todas == state.todas)) {
      return;
    }

    emit(state.copyWith(vista: event.vista, todas: todas));
    add(MarketplaceSolicitadas(todas: event.todas));
  }

  void _cambiarCategoria(
    FiltroCategoriaCambiado event,
    Emitter<MarketplaceState> emit,
  ) {
    emit(
      state.copyWith(
        categoria: event.categoria,
        limpiarCategoria: event.categoria == null,
      ),
    );
  }

  void _cambiarBusqueda(
    BusquedaMarketplaceCambiada event,
    Emitter<MarketplaceState> emit,
  ) {
    emit(state.copyWith(busqueda: event.texto));
  }

  void _cambiarTodas(
    FiltroTodasCambiado event,
    Emitter<MarketplaceState> emit,
  ) {
    emit(state.copyWith(todas: event.todas, vista: MarketplaceVista.catalogo));
    add(MarketplaceSolicitadas(todas: event.todas));
  }

  Future<void> _guardar(
    PublicacionGuardada event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(
      state.copyWith(
        guardando: true,
        procesandoId: event.id,
        limpiarProcesando: event.id == null,
        limpiarMensaje: true,
      ),
    );

    final resultado = event.id == null
        ? await _crear(
            titulo: event.titulo,
            descripcion: event.descripcion,
            precio: event.precio,
            categoria: event.categoria,
            condicion: event.condicion,
            foto: event.foto,
          )
        : await _actualizar(
            id: event.id!,
            titulo: event.titulo,
            descripcion: event.descripcion,
            precio: event.precio,
            categoria: event.categoria,
            condicion: event.condicion,
            foto: event.foto,
          );

    resultado.fold(
      (failure) => emit(
        state.copyWith(
          guardando: false,
          limpiarProcesando: true,
          mensaje: failure.message,
        ),
      ),
      (publicacion) {
        if (event.id == null) {
          _aplicarCreada(publicacion, emit);
          return;
        }

        emit(
          state.copyWith(
            publicaciones: _reemplazar(event.id!, publicacion),
            guardando: false,
            limpiarProcesando: true,
            mensaje: 'Publicación actualizada.',
          ),
        );
      },
    );
  }

  void _aplicarCreada(
    PublicacionMarketplace publicacion,
    Emitter<MarketplaceState> emit,
  ) {
    emit(
      state.copyWith(
        vista: MarketplaceVista.mias,
        todas: false,
        publicaciones: [
          publicacion,
          ...state.publicaciones.where(
            (p) => p.esMia && p.estaDisponible && p.id != publicacion.id,
          ),
        ],
        guardando: false,
        limpiarProcesando: true,
        mensaje: publicacion.esPendiente
            ? 'Publicación enviada a revisión.'
            : 'Publicación creada.',
      ),
    );
  }

  Future<void> _retirarPublicacion(
    PublicacionRetiradaSolicitada event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(state.copyWith(procesandoId: event.id, limpiarMensaje: true));

    final resultado = await _retirar(event.id);

    resultado.fold(
      (failure) => emit(
        state.copyWith(limpiarProcesando: true, mensaje: failure.message),
      ),
      (publicacion) => emit(
        state.copyWith(
          publicaciones: _aplicarCambioDeEstado(event.id, publicacion),
          limpiarProcesando: true,
          mensaje: 'Publicación retirada de la venta.',
        ),
      ),
    );
  }

  Future<void> _venderPublicacion(
    PublicacionVendidaSolicitada event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(state.copyWith(procesandoId: event.id, limpiarMensaje: true));

    final resultado = await _vender(event.id);

    resultado.fold(
      (failure) => emit(
        state.copyWith(limpiarProcesando: true, mensaje: failure.message),
      ),
      (publicacion) => emit(
        state.copyWith(
          publicaciones: _aplicarCambioDeEstado(event.id, publicacion),
          limpiarProcesando: true,
          mensaje: 'Publicación marcada como vendida.',
        ),
      ),
    );
  }

  Future<void> _eliminarPublicacion(
    PublicacionEliminadaSolicitada event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(state.copyWith(procesandoId: event.id, limpiarMensaje: true));

    final resultado = await _eliminar(id: event.id, motivo: event.motivo);

    resultado.fold(
      (failure) => emit(
        state.copyWith(limpiarProcesando: true, mensaje: failure.message),
      ),
      (_) => emit(
        state.copyWith(
          publicaciones: _quitar(event.id),
          limpiarProcesando: true,
          mensaje: 'Publicación eliminada.',
        ),
      ),
    );
  }

  List<PublicacionMarketplace> _reemplazar(
    String id,
    PublicacionMarketplace publicacion,
  ) {
    return state.publicaciones
        .map((p) => p.id == id ? publicacion : p)
        .toList(growable: false);
  }

  List<PublicacionMarketplace> _quitar(String id) {
    return state.publicaciones
        .where((publicacion) => publicacion.id != id)
        .toList(growable: false);
  }

  List<PublicacionMarketplace> _aplicarCambioDeEstado(
    String id,
    PublicacionMarketplace publicacion,
  ) {
    final reemplazada = _reemplazar(id, publicacion);

    switch (state.vista) {
      case MarketplaceVista.catalogo:
        return state.todas ? reemplazada : _quitar(id);
      case MarketplaceVista.mias:
        return _quitar(id);
      case MarketplaceVista.favoritos:
        return publicacion.estaVendida || publicacion.estaDisponible
            ? reemplazada
            : _quitar(id);
      case MarketplaceVista.historial:
        return reemplazada;
      case MarketplaceVista.eliminadas:
        return publicacion.estado.estaEliminada ? reemplazada : _quitar(id);
      case MarketplaceVista.solicitudes:
        return _quitar(id);
    }
  }

  Future<void> _aprobarSolicitudSolicitada(
    SolicitudAprobadaSolicitada event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(state.copyWith(procesandoId: event.id, limpiarMensaje: true));

    final resultado = await _aprobarSolicitud(event.id);

    resultado.fold(
      (failure) => emit(
        state.copyWith(limpiarProcesando: true, mensaje: failure.message),
      ),
      (publicacion) {
        final restantes = _quitar(event.id);
        emit(
          state.copyWith(
            publicaciones: restantes,
            pendientes: restantes.length,
            limpiarProcesando: true,
            mensaje: 'Publicación aprobada.',
          ),
        );
      },
    );
  }

  Future<void> _rechazarSolicitudSolicitada(
    SolicitudRechazadaSolicitada event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(state.copyWith(procesandoId: event.id, limpiarMensaje: true));

    final resultado = await _rechazarSolicitud(
      id: event.id,
      motivo: event.motivo,
    );

    resultado.fold(
      (failure) => emit(
        state.copyWith(limpiarProcesando: true, mensaje: failure.message),
      ),
      (publicacion) {
        final restantes = _quitar(event.id);
        emit(
          state.copyWith(
            publicaciones: restantes,
            pendientes: restantes.length,
            limpiarProcesando: true,
            mensaje: 'Solicitud rechazada.',
          ),
        );
      },
    );
  }

  Future<void> _alternarFavorito(
    FavoritoMarketplaceAlternado event,
    Emitter<MarketplaceState> emit,
  ) async {
    final resultado = await _favorito(id: event.id, favorito: event.favorito);

    resultado.fold(
      (failure) => emit(state.copyWith(mensaje: failure.message)),
      (esFavorita) {
        var publicaciones = state.publicaciones
            .map(
              (publicacion) => publicacion.id == event.id
                  ? publicacion.copyWith(esFavorita: esFavorita)
                  : publicacion,
            )
            .toList(growable: false);

        if (state.vista == MarketplaceVista.favoritos && !esFavorita) {
          publicaciones = publicaciones
              .where((publicacion) => publicacion.id != event.id)
              .toList(growable: false);
        }

        emit(
          state.copyWith(
            publicaciones: publicaciones,
            mensaje: esFavorita
                ? 'Agregado a favoritos.'
                : 'Quitado de favoritos.',
          ),
        );
      },
    );
  }
}
