import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:torre_manager_frontend/core/errors/failures.dart';
import 'package:torre_manager_frontend/features/marketplace/domain/entities/categoria_producto.dart';
import 'package:torre_manager_frontend/features/marketplace/domain/entities/condicion_producto.dart';
import 'package:torre_manager_frontend/features/marketplace/domain/entities/estado_publicacion.dart';
import 'package:torre_manager_frontend/features/marketplace/domain/entities/publicacion_foto.dart';
import 'package:torre_manager_frontend/features/marketplace/domain/entities/publicacion_marketplace.dart';
import 'package:torre_manager_frontend/features/marketplace/domain/entities/solicitudes_marketplace.dart';
import 'package:torre_manager_frontend/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:torre_manager_frontend/features/marketplace/domain/usecases/actualizar_publicacion_usecase.dart';
import 'package:torre_manager_frontend/features/marketplace/domain/usecases/alternar_favorito_usecase.dart';
import 'package:torre_manager_frontend/features/marketplace/domain/usecases/aprobar_solicitud_usecase.dart';
import 'package:torre_manager_frontend/features/marketplace/domain/usecases/crear_publicacion_usecase.dart';
import 'package:torre_manager_frontend/features/marketplace/domain/usecases/eliminar_publicacion_usecase.dart';
import 'package:torre_manager_frontend/features/marketplace/domain/usecases/listar_favoritos_marketplace_usecase.dart';
import 'package:torre_manager_frontend/features/marketplace/domain/usecases/listar_historial_marketplace_usecase.dart';
import 'package:torre_manager_frontend/features/marketplace/domain/usecases/listar_mis_publicaciones_usecase.dart';
import 'package:torre_manager_frontend/features/marketplace/domain/usecases/listar_publicaciones_usecase.dart';
import 'package:torre_manager_frontend/features/marketplace/domain/usecases/listar_solicitudes_usecase.dart';
import 'package:torre_manager_frontend/features/marketplace/domain/usecases/marcar_publicacion_vendida_usecase.dart';
import 'package:torre_manager_frontend/features/marketplace/domain/usecases/rechazar_solicitud_usecase.dart';
import 'package:torre_manager_frontend/features/marketplace/domain/usecases/retirar_publicacion_usecase.dart';
import 'package:torre_manager_frontend/features/marketplace/presentation/bloc/marketplace_bloc.dart';

const _refrigerador = PublicacionMarketplace(
  id: '1',
  titulo: 'Refrigerador',
  descripcion: 'Funciona perfecto.',
  precio: 150000,
  categoria: CategoriaProducto.electrodomesticos,
  condicion: CondicionProducto.usado,
  estado: EstadoPublicacion.disponible,
  fotoUrl: null,
  esMia: false,
  esFavorita: false,
  puedeEditar: false,
  puedeEliminar: false,
  puedeRetirar: false,
  puedeMarcarVendida: false,
  contactoDisponible: false,
  vendidoEn: null,
  motivoEliminacion: null,
  eliminadoPorRol: null,
  eliminadoEn: null,
  motivoRechazo: null,
  rechazadoEn: null,
  creadoEn: null,
);

const _mesa = PublicacionMarketplace(
  id: '2',
  titulo: 'Mesa de comedor',
  descripcion: 'Madera sólida.',
  precio: 0,
  categoria: CategoriaProducto.muebles,
  condicion: CondicionProducto.nuevo,
  estado: EstadoPublicacion.disponible,
  fotoUrl: null,
  esMia: false,
  esFavorita: false,
  puedeEditar: false,
  puedeEliminar: false,
  puedeRetirar: false,
  puedeMarcarVendida: false,
  contactoDisponible: false,
  vendidoEn: null,
  motivoEliminacion: null,
  eliminadoPorRol: null,
  eliminadoEn: null,
  motivoRechazo: null,
  rechazadoEn: null,
  creadoEn: null,
);

const _vendida = PublicacionMarketplace(
  id: '3',
  titulo: 'Bicicleta',
  descripcion: 'Vendida a un vecino.',
  precio: 80000,
  categoria: CategoriaProducto.otros,
  condicion: CondicionProducto.usado,
  estado: EstadoPublicacion.vendida,
  fotoUrl: null,
  esMia: false,
  esFavorita: true,
  puedeEditar: false,
  puedeEliminar: false,
  puedeRetirar: false,
  puedeMarcarVendida: false,
  contactoDisponible: false,
  vendidoEn: null,
  motivoEliminacion: null,
  eliminadoPorRol: null,
  eliminadoEn: null,
  motivoRechazo: null,
  rechazadoEn: null,
  creadoEn: null,
);

PublicacionMarketplace _conEstado(
  PublicacionMarketplace base,
  EstadoPublicacion estado, {
  String? titulo,
  bool esMia = true,
  bool esFavorita = false,
}) {
  return PublicacionMarketplace(
    id: base.id,
    titulo: titulo ?? base.titulo,
    descripcion: base.descripcion,
    precio: base.precio,
    categoria: base.categoria,
    condicion: base.condicion,
    estado: estado,
    fotoUrl: base.fotoUrl,
    esMia: esMia,
    esFavorita: esFavorita,
    puedeEditar: false,
    puedeEliminar: false,
    puedeRetirar: false,
    puedeMarcarVendida: false,
    contactoDisponible: false,
    vendidoEn: base.vendidoEn,
    motivoEliminacion: base.motivoEliminacion,
    eliminadoPorRol: base.eliminadoPorRol,
    eliminadoEn: base.eliminadoEn,
    motivoRechazo: base.motivoRechazo,
    rechazadoEn: base.rechazadoEn,
    creadoEn: base.creadoEn,
  );
}

class _FakeMarketplaceRepository implements MarketplaceRepositoryInterface {
  List<PublicacionMarketplace> catalogo = const [_refrigerador, _mesa];
  List<PublicacionMarketplace> favoritosLista = const [_vendida];
  bool fallaListado = false;
  int listados = 0;
  bool? ultimoTodas;
  EstadoPublicacion? ultimoEstado;
  String? idRetirado;
  String? idVendido;
  String? idEliminado;
  String? motivoEliminado;
  bool? ultimoFavorito;
  bool creo = false;
  bool actualizo = false;
  PublicacionMarketplace? actualizada;
  PublicacionMarketplace? retirada;
  PublicacionMarketplace? vendida;
  Completer<Either<Failure, PublicacionMarketplace>>? retirarCompleter;
  List<PublicacionMarketplace> solicitudesLista = const [];
  int solicitudesLlamadas = 0;
  String? solicitudAprobada;
  String? solicitudRechazada;
  String? motivoRechazado;
  EstadoPublicacion estadoCrear = EstadoPublicacion.disponible;

  @override
  Future<Either<Failure, List<PublicacionMarketplace>>> listar({
    bool todas = false,
    EstadoPublicacion? estado,
  }) async {
    listados++;
    ultimoTodas = todas;
    ultimoEstado = estado;
    if (fallaListado) {
      return const Left(ServerFailure('Sin conexión.'));
    }
    return Right(catalogo);
  }

  @override
  Future<Either<Failure, List<PublicacionMarketplace>>>
  misPublicaciones() async {
    listados++;
    return Right(catalogo.where((p) => p.esMia).toList());
  }

  @override
  Future<Either<Failure, List<PublicacionMarketplace>>> historial() async {
    listados++;
    return const Right([_vendida]);
  }

  @override
  Future<Either<Failure, List<PublicacionMarketplace>>> favoritos() async {
    listados++;
    return Right(favoritosLista);
  }

  @override
  Future<Either<Failure, PublicacionMarketplace>> crear({
    required String titulo,
    required String descripcion,
    required int precio,
    required CategoriaProducto categoria,
    required CondicionProducto condicion,
    PublicacionFoto? foto,
  }) async {
    creo = true;
    final creada = PublicacionMarketplace(
      id: '${catalogo.length + 1}',
      titulo: titulo,
      descripcion: descripcion,
      precio: precio,
      categoria: categoria,
      condicion: condicion,
      estado: estadoCrear,
      fotoUrl: foto == null ? null : 'http://foto',
      esMia: true,
      esFavorita: false,
      puedeEditar: true,
      puedeEliminar: true,
      puedeRetirar: true,
      puedeMarcarVendida: true,
      contactoDisponible: false,
      vendidoEn: null,
      motivoEliminacion: null,
      eliminadoPorRol: null,
      eliminadoEn: null,
      motivoRechazo: null,
      rechazadoEn: null,
      creadoEn: null,
    );
    catalogo = [...catalogo, creada];
    return Right(creada);
  }

  @override
  Future<Either<Failure, PublicacionMarketplace>> actualizar({
    required String id,
    required String titulo,
    required String descripcion,
    required int precio,
    required CategoriaProducto categoria,
    required CondicionProducto condicion,
    PublicacionFoto? foto,
  }) async {
    actualizo = true;
    return Right(actualizada ?? _refrigerador);
  }

  @override
  Future<Either<Failure, PublicacionMarketplace>> retirar(String id) async {
    idRetirado = id;
    if (retirarCompleter != null) {
      return retirarCompleter!.future;
    }
    return Right(
      retirada ?? _conEstado(_refrigerador, EstadoPublicacion.retirada),
    );
  }

  @override
  Future<Either<Failure, PublicacionMarketplace>> vender(String id) async {
    idVendido = id;
    return Right(
      vendida ?? _conEstado(_refrigerador, EstadoPublicacion.vendida),
    );
  }

  @override
  Future<Either<Failure, bool>> eliminar({
    required String id,
    required String motivo,
  }) async {
    idEliminado = id;
    motivoEliminado = motivo;
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> alternarFavorito({
    required String id,
    required bool favorito,
  }) async {
    ultimoFavorito = favorito;
    return Right(favorito);
  }

  @override
  Future<Either<Failure, SolicitudesMarketplace>> solicitudes() async {
    solicitudesLlamadas++;
    return Right(
      SolicitudesMarketplace(
        pendientes: solicitudesLista.length,
        solicitudes: solicitudesLista,
      ),
    );
  }

  @override
  Future<Either<Failure, PublicacionMarketplace>> aprobarSolicitud(
    String id,
  ) async {
    solicitudAprobada = id;
    return Right(_conEstado(_refrigerador, EstadoPublicacion.disponible));
  }

  @override
  Future<Either<Failure, PublicacionMarketplace>> rechazarSolicitud({
    required String id,
    required String motivo,
  }) async {
    solicitudRechazada = id;
    motivoRechazado = motivo;
    return Right(_conEstado(_refrigerador, EstadoPublicacion.rechazada));
  }
}

MarketplaceBloc _crearBloc(_FakeMarketplaceRepository repository) {
  return MarketplaceBloc(
    listar: ListarPublicacionesUseCase(repository),
    listarMias: ListarMisPublicacionesUseCase(repository),
    listarFavoritos: ListarFavoritosMarketplaceUseCase(repository),
    listarHistorial: ListarHistorialMarketplaceUseCase(repository),
    crear: CrearPublicacionUseCase(repository),
    actualizar: ActualizarPublicacionUseCase(repository),
    retirar: RetirarPublicacionUseCase(repository),
    vender: MarcarPublicacionVendidaUseCase(repository),
    eliminar: EliminarPublicacionUseCase(repository),
    favorito: AlternarFavoritoUseCase(repository),
    listarSolicitudes: ListarSolicitudesUseCase(repository),
    aprobarSolicitud: AprobarSolicitudMarketplaceUseCase(repository),
    rechazarSolicitud: RechazarSolicitudMarketplaceUseCase(repository),
  );
}

void main() {
  late _FakeMarketplaceRepository repository;
  late MarketplaceBloc bloc;
  late List<MarketplaceState> estados;

  setUp(() {
    repository = _FakeMarketplaceRepository();
    bloc = _crearBloc(repository);
    estados = [];
    bloc.stream.listen(estados.add);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('carga el catálogo del proyecto', () async {
    bloc.add(const MarketplaceSolicitadas());
    await pumpEventQueue();

    expect(estados.first.cargando, isTrue);
    expect(estados.last.status, MarketplaceStatus.cargado);
    expect(estados.last.publicaciones, repository.catalogo);
    expect(repository.listados, 1);
    expect(repository.ultimoTodas, isFalse);
  });

  test('el administrador solicita todas las publicaciones', () async {
    bloc.add(const MarketplaceSolicitadas(todas: true));
    await pumpEventQueue();

    expect(repository.ultimoTodas, isTrue);
    expect(estados.last.todas, isTrue);
  });

  test('el administrador consulta solo las publicaciones eliminadas', () async {
    bloc.add(const VistaMarketplaceCambiada(MarketplaceVista.eliminadas));
    await pumpEventQueue();

    expect(estados.last.vista, MarketplaceVista.eliminadas);
    expect(repository.ultimoTodas, isTrue);
    expect(repository.ultimoEstado, EstadoPublicacion.eliminada);
  });

  test('vuelve de eliminadas a disponibles sin filtro de estado', () async {
    bloc.add(const VistaMarketplaceCambiada(MarketplaceVista.eliminadas));
    await pumpEventQueue();

    bloc.add(
      const VistaMarketplaceCambiada(MarketplaceVista.catalogo, todas: false),
    );
    await pumpEventQueue();

    expect(estados.last.vista, MarketplaceVista.catalogo);
    expect(repository.ultimoTodas, isFalse);
    expect(repository.ultimoEstado, isNull);
  });

  test('filtra por categoría y búsqueda sin volver a consultar', () async {
    bloc.add(const MarketplaceSolicitadas());
    await pumpEventQueue();
    final listadosIniciales = repository.listados;

    bloc.add(const FiltroCategoriaCambiado(CategoriaProducto.muebles));
    await pumpEventQueue();

    expect(estados.last.publicacionesVisibles, const [_mesa]);
    expect(repository.listados, listadosIniciales);

    bloc.add(const FiltroCategoriaCambiado(null));
    bloc.add(const BusquedaMarketplaceCambiada('REFRIGERADOR'));
    await pumpEventQueue();

    expect(estados.last.publicacionesVisibles, const [_refrigerador]);
    expect(repository.listados, listadosIniciales);
  });

  test(
    'oculta las publicaciones propias y eliminadas del catálogo general',
    () {
      final propia = _conEstado(
        _mesa,
        EstadoPublicacion.disponible,
        titulo: 'Propia',
        esMia: true,
      );
      final eliminada = _conEstado(
        _vendida,
        EstadoPublicacion.eliminada,
        esMia: false,
      );
      final state = MarketplaceState(
        publicaciones: [propia, _refrigerador, eliminada],
      );

      expect(state.publicacionesVisibles, const [_refrigerador]);
    },
  );

  test('oculta las publicaciones propias de la vista de eliminadas', () {
    final propia = _conEstado(
      _mesa,
      EstadoPublicacion.eliminada,
      titulo: 'Propia eliminada',
      esMia: true,
    );
    final ajena = _conEstado(
      _vendida,
      EstadoPublicacion.eliminada,
      titulo: 'Ajena eliminada',
      esMia: false,
    );
    final state = MarketplaceState(
      publicaciones: [propia, ajena],
      vista: MarketplaceVista.eliminadas,
    );

    expect(state.publicacionesVisibles, [ajena]);
  });

  test('cambia a la vista de favoritos', () async {
    bloc.add(const VistaMarketplaceCambiada(MarketplaceVista.favoritos));
    await pumpEventQueue();

    expect(estados.last.vista, MarketplaceVista.favoritos);
    expect(estados.last.publicaciones, repository.favoritosLista);
  });

  test(
    'crea una publicación y la muestra solo en mis publicaciones sin recargar',
    () async {
      bloc.add(const MarketplaceSolicitadas());
      await pumpEventQueue();
      final listadosIniciales = repository.listados;

      bloc.add(
        const PublicacionGuardada(
          titulo: 'Silla',
          descripcion: 'Silla de madera.',
          precio: 0,
          categoria: CategoriaProducto.muebles,
          condicion: CondicionProducto.nuevo,
        ),
      );
      await pumpEventQueue();

      expect(repository.creo, isTrue);
      expect(estados.last.mensaje, 'Publicación creada.');
      expect(estados.last.guardando, isFalse);
      expect(estados.last.procesandoId, isNull);
      expect(repository.listados, listadosIniciales);
      expect(estados.last.vista, MarketplaceVista.mias);
      expect(estados.last.todas, isFalse);
      expect(estados.last.publicaciones.length, 1);
      expect(estados.last.publicaciones.first.titulo, 'Silla');
      expect(estados.last.publicaciones.every((p) => p.esMia), isTrue);
    },
  );

  test('edita una publicación sin recargar el listado', () async {
    bloc.add(const MarketplaceSolicitadas());
    await pumpEventQueue();
    final listadosIniciales = repository.listados;
    repository.actualizada = _conEstado(
      _refrigerador,
      EstadoPublicacion.disponible,
      titulo: 'Refrigerador actualizado',
    );

    bloc.add(
      const PublicacionGuardada(
        id: '1',
        titulo: 'Refrigerador actualizado',
        descripcion: 'Funciona perfecto.',
        precio: 150000,
        categoria: CategoriaProducto.electrodomesticos,
        condicion: CondicionProducto.usado,
      ),
    );
    await pumpEventQueue();

    expect(repository.actualizo, isTrue);
    expect(repository.listados, listadosIniciales);
    expect(estados.last.guardando, isFalse);
    expect(estados.last.procesandoId, isNull);
    expect(
      estados.last.publicaciones.firstWhere((p) => p.id == '1').titulo,
      'Refrigerador actualizado',
    );
  });

  test('retira y marca vendida una publicación sin recargar', () async {
    bloc.add(const MarketplaceSolicitadas());
    await pumpEventQueue();
    final listadosIniciales = repository.listados;

    bloc.add(const PublicacionRetiradaSolicitada('1'));
    await pumpEventQueue();

    expect(repository.idRetirado, '1');
    expect(estados.last.mensaje, 'Publicación retirada de la venta.');
    expect(estados.last.procesandoId, isNull);
    expect(
      estados.last.publicaciones.map((p) => p.id).toList(),
      isNot(contains('1')),
    );

    repository.vendida = _conEstado(_mesa, EstadoPublicacion.vendida);
    bloc.add(const PublicacionVendidaSolicitada('2'));
    await pumpEventQueue();

    expect(repository.idVendido, '2');
    expect(estados.last.mensaje, 'Publicación marcada como vendida.');
    expect(estados.last.procesandoId, isNull);
    expect(estados.last.publicaciones, isEmpty);
    expect(repository.listados, listadosIniciales);
  });

  test('elimina con motivo de moderación sin recargar', () async {
    bloc.add(const MarketplaceSolicitadas());
    await pumpEventQueue();
    final listadosIniciales = repository.listados;

    bloc.add(
      const PublicacionEliminadaSolicitada(
        id: '2',
        motivo: 'Incumple las normas del condominio.',
      ),
    );
    await pumpEventQueue();

    expect(repository.idEliminado, '2');
    expect(repository.motivoEliminado, 'Incumple las normas del condominio.');
    expect(estados.last.mensaje, 'Publicación eliminada.');
    expect(estados.last.procesandoId, isNull);
    expect(estados.last.publicaciones.map((p) => p.id).toList(), ['1']);
    expect(repository.listados, listadosIniciales);
  });

  test('expone la publicación en proceso y la quita al terminar', () async {
    bloc.add(const MarketplaceSolicitadas());
    await pumpEventQueue();

    final completer = Completer<Either<Failure, PublicacionMarketplace>>();
    repository.retirarCompleter = completer;

    bloc.add(const PublicacionRetiradaSolicitada('1'));
    await pumpEventQueue();

    expect(estados.last.procesandoId, '1');
    expect(estados.last.ocupado, isTrue);

    completer.complete(
      Right(_conEstado(_refrigerador, EstadoPublicacion.retirada)),
    );
    await pumpEventQueue();

    expect(estados.last.procesandoId, isNull);
    expect(estados.last.ocupado, isFalse);
    expect(
      estados.last.publicaciones.map((p) => p.id).toList(),
      isNot(contains('1')),
    );
  });

  test('quita un favorito desde la vista de favoritos', () async {
    bloc.add(const VistaMarketplaceCambiada(MarketplaceVista.favoritos));
    await pumpEventQueue();

    bloc.add(const FavoritoMarketplaceAlternado(id: '3', favorito: false));
    await pumpEventQueue();

    expect(repository.ultimoFavorito, isFalse);
    expect(estados.last.publicaciones, isEmpty);
    expect(estados.last.mensaje, 'Quitado de favoritos.');
  });

  test('conserva el mensaje de error del repositorio', () async {
    repository.fallaListado = true;
    bloc.add(const MarketplaceSolicitadas());
    await pumpEventQueue();

    expect(estados.last.status, MarketplaceStatus.error);
    expect(estados.last.mensaje, 'Sin conexión.');
  });

  test('carga las solicitudes pendientes de aprobación', () async {
    repository.solicitudesLista = [
      _conEstado(_refrigerador, EstadoPublicacion.pendiente),
    ];

    bloc.add(const VistaMarketplaceCambiada(MarketplaceVista.solicitudes));
    await pumpEventQueue();

    expect(repository.solicitudesLlamadas, 1);
    expect(estados.last.vista, MarketplaceVista.solicitudes);
    expect(estados.last.publicaciones, hasLength(1));
    expect(estados.last.pendientes, 1);
  });

  test('aprobar una solicitud la quita y baja el contador', () async {
    repository.solicitudesLista = [
      _conEstado(_refrigerador, EstadoPublicacion.pendiente),
    ];

    bloc.add(const VistaMarketplaceCambiada(MarketplaceVista.solicitudes));
    await pumpEventQueue();

    bloc.add(const SolicitudAprobadaSolicitada('1'));
    await pumpEventQueue();

    expect(repository.solicitudAprobada, '1');
    expect(estados.last.publicaciones, isEmpty);
    expect(estados.last.pendientes, 0);
    expect(estados.last.mensaje, 'Publicación aprobada.');
  });

  test('rechazar una solicitud registra el motivo y baja el contador', () async {
    repository.solicitudesLista = [
      _conEstado(_refrigerador, EstadoPublicacion.pendiente),
    ];

    bloc.add(const VistaMarketplaceCambiada(MarketplaceVista.solicitudes));
    await pumpEventQueue();

    bloc.add(
      const SolicitudRechazadaSolicitada(
        id: '1',
        motivo: 'Producto no permitido.',
      ),
    );
    await pumpEventQueue();

    expect(repository.solicitudRechazada, '1');
    expect(repository.motivoRechazado, 'Producto no permitido.');
    expect(estados.last.publicaciones, isEmpty);
    expect(estados.last.pendientes, 0);
    expect(estados.last.mensaje, 'Solicitud rechazada.');
  });

  test('una publicación pendiente avisa que va a revisión', () async {
    repository.estadoCrear = EstadoPublicacion.pendiente;

    bloc.add(
      const PublicacionGuardada(
        titulo: 'Parlante',
        descripcion: 'Buen estado.',
        precio: 20000,
        categoria: CategoriaProducto.otros,
        condicion: CondicionProducto.usado,
      ),
    );
    await pumpEventQueue();

    expect(estados.last.vista, MarketplaceVista.mias);
    expect(estados.last.mensaje, 'Publicación enviada a revisión.');
  });
}
