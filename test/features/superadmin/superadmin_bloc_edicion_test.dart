import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:torre_manager_frontend/core/errors/failures.dart';
import 'package:torre_manager_frontend/features/infraestructura/domain/entities/agrupacion.dart';
import 'package:torre_manager_frontend/features/infraestructura/domain/entities/arbol_infraestructura.dart';
import 'package:torre_manager_frontend/features/infraestructura/domain/entities/asignacion_accesoria.dart';
import 'package:torre_manager_frontend/features/infraestructura/domain/entities/proyecto.dart';
import 'package:torre_manager_frontend/features/infraestructura/domain/entities/tipo_agrupacion.dart';
import 'package:torre_manager_frontend/features/infraestructura/domain/entities/tipo_asignacion.dart';
import 'package:torre_manager_frontend/features/infraestructura/domain/entities/tipo_unidad_accesoria.dart';
import 'package:torre_manager_frontend/features/infraestructura/domain/entities/unidad_accesoria.dart';
import 'package:torre_manager_frontend/features/infraestructura/domain/entities/unidad_principal.dart';
import 'package:torre_manager_frontend/features/infraestructura/domain/repositories/infraestructura_repository.dart';
import 'package:torre_manager_frontend/features/infraestructura/domain/usecases/asignar_unidad_accesoria_usecase.dart';
import 'package:torre_manager_frontend/features/infraestructura/domain/usecases/crear_unidades_accesorias_en_lote_usecase.dart';
import 'package:torre_manager_frontend/features/infraestructura/domain/usecases/obtener_arbol_infraestructura_usecase.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/entities/administrador.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/entities/definicion_agrupacion.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/entities/instalacion_extra.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/entities/modulo_sistema.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/entities/proyecto_detalle.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/entities/resumen_proyecto.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/entities/tipo_condominio.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/repositories/superadmin_repository.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/usecases/actualizar_proyecto_usecase.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/usecases/crear_proyecto_usecase.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/usecases/listar_proyectos_usecase.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/usecases/obtener_proyecto_usecase.dart';
import 'package:torre_manager_frontend/features/superadmin/presentation/bloc/superadmin_bloc.dart';

class _FakeSuperadminRepository implements SuperadminRepositoryInterface {
  String? proyectoActualizadoId;

  @override
  Future<Either<Failure, ProyectoDetalle>> obtenerProyecto(String id) async {
    return Right(_detalle(nombre: 'Proyecto original', id: id));
  }

  @override
  Future<Either<Failure, ProyectoDetalle>> actualizarProyecto({
    required String id,
    required String nombre,
    String? descripcion,
    required List<ModuloSistema> modulos,
    required List<InstalacionExtra> instalaciones,
    required List<String> adminIds,
  }) async {
    proyectoActualizadoId = id;

    return Right(
      _detalle(
        id: id,
        nombre: nombre,
        descripcion: descripcion,
        modulos: modulos,
        instalaciones: instalaciones,
        adminIds: adminIds,
      ),
    );
  }

  @override
  Future<Either<Failure, List<ResumenProyecto>>> listarProyectos() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Administrador>>> listarAdministradores() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Administrador>> crearAdministrador({
    required String nombre,
    required String correo,
    required String password,
  }) async {
    return const Right(
      Administrador(id: '1', nombre: 'Admin', correo: 'admin@example.test'),
    );
  }

  @override
  Future<Either<Failure, ProyectoDetalle>> crearProyecto({
    required String nombre,
    String? descripcion,
    required TipoCondominio tipoCondominio,
    required List<ModuloSistema> modulos,
    required List<DefinicionAgrupacion> agrupaciones,
    required List<InstalacionExtra> instalaciones,
    required List<String> adminIds,
    int estacionamientos = 0,
    int bodegas = 0,
  }) async {
    return Right(_detalle(nombre: nombre, id: '1'));
  }

  @override
  Future<Either<Failure, List<ProyectoDetalle>>> listarMisProyectos() async {
    return const Right([]);
  }

  ProyectoDetalle _detalle({
    required String id,
    required String nombre,
    String? descripcion,
    List<ModuloSistema> modulos = const [ModuloSistema.infraestructura],
    List<InstalacionExtra> instalaciones = const [],
    List<String> adminIds = const ['2'],
  }) {
    return ProyectoDetalle(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      tipoCondominio: TipoCondominio.torres,
      modulos: modulos,
      instalacionesExtra: instalaciones,
      adminIds: adminIds,
    );
  }
}

class _FakeInfraestructuraRepository
    implements InfraestructuraRepositoryInterface {
  _FakeInfraestructuraRepository({required this.arbol});

  final ArbolInfraestructura arbol;
  Failure? failure;
  int? loteCantidad;
  TipoUnidadAccesoria? loteTipo;
  TipoAsignacion? loteAsignacion;
  final List<AsignacionAccesoria> asignacionesRecibidas = [];

  @override
  Future<Either<Failure, ArbolInfraestructura>> obtenerArbol({
    required String proyectoId,
  }) async {
    if (failure != null) return Left(failure!);

    return Right(arbol);
  }

  @override
  Future<Either<Failure, List<UnidadAccesoria>>> crearUnidadesAccesoriasEnLote({
    required String proyectoId,
    required TipoUnidadAccesoria tipo,
    required int cantidad,
    TipoAsignacion? asignacion,
  }) async {
    loteCantidad = cantidad;
    loteTipo = tipo;
    loteAsignacion = asignacion;
    return Right(
      List.generate(
        cantidad,
        (index) => UnidadAccesoria(
          id: 'nuevo-$index',
          proyectoId: proyectoId,
          identificador: 'N-${index + 1}',
          tipo: tipo,
          asignacion: asignacion,
          unidadPrincipalId: null,
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, UnidadAccesoria>> asignarUnidadAccesoria({
    required String unidadAccesoriaId,
    required TipoAsignacion? asignacion,
    String? unidadPrincipalId,
  }) async {
    asignacionesRecibidas.add(
      AsignacionAccesoria(
        unidadAccesoriaId: unidadAccesoriaId,
        asignacion: asignacion!,
        unidadPrincipalId: unidadPrincipalId,
      ),
    );

    return Right(
      UnidadAccesoria(
        id: unidadAccesoriaId,
        proyectoId: '7',
        identificador: 'E-01',
        tipo: TipoUnidadAccesoria.estacionamiento,
        asignacion: asignacion,
        unidadPrincipalId: unidadPrincipalId,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ArbolInfraestructura _arbolEjemplo() {
  return ArbolInfraestructura(
    proyecto: const Proyecto(id: '7', nombre: 'Proyecto'),
    agrupaciones: [
      ArbolAgrupacion(
        agrupacion: const Agrupacion(
          id: '1',
          proyectoId: '7',
          nombre: 'Torre A',
          tipo: TipoAgrupacion.torre,
        ),
        unidadesPrincipales: [
          ArbolUnidadPrincipal(
            unidadPrincipal: const UnidadPrincipal(
              id: '1',
              agrupacionId: '1',
              identificador: '101',
            ),
            unidadesAccesorias: [
              const UnidadAccesoria(
                id: '1',
                proyectoId: '7',
                identificador: 'E-01',
                tipo: TipoUnidadAccesoria.estacionamiento,
                asignacion: TipoAsignacion.departamento,
                unidadPrincipalId: '1',
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

void main() {
  late _FakeSuperadminRepository repository;
  late _FakeInfraestructuraRepository infraestructuraRepository;
  late SuperadminBloc bloc;

  setUp(() {
    repository = _FakeSuperadminRepository();
    infraestructuraRepository = _FakeInfraestructuraRepository(
      arbol: _arbolEjemplo(),
    );
    bloc = SuperadminBloc(
      listarProyectosUseCase: ListarProyectosUseCase(repository),
      crearProyectoUseCase: CrearProyectoUseCase(repository),
      obtenerProyectoUseCase: ObtenerProyectoUseCase(repository),
      actualizarProyectoUseCase: ActualizarProyectoUseCase(repository),
      obtenerEstructuraUseCase: ObtenerArbolInfraestructuraUseCase(
        infraestructuraRepository,
      ),
      crearUnidadesAccesoriasEnLoteUseCase:
          CrearUnidadesAccesoriasEnLoteUseCase(infraestructuraRepository),
      asignarUnidadAccesoriaUseCase: AsignarUnidadAccesoriaUseCase(
        infraestructuraRepository,
      ),
    );
  });

  tearDown(() => bloc.close());

  test('carga el detalle del proyecto al solicitar la edición', () async {
    bloc.add(const ProyectoEdicionSolicitada('7'));

    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<SuperadminState>()
            .having((s) => s.proyectoEnEdicion?.id, 'id', '7')
            .having((s) => s.cargandoDetalle, 'cargandoDetalle', false),
      ),
    );
  });

  test('actualiza el proyecto y notifica el éxito', () async {
    bloc.add(
      const ProyectoActualizado(
        id: '7',
        nombre: 'Proyecto editado',
        descripcion: 'Nueva descripción',
        modulos: [ModuloSistema.infraestructura, ModuloSistema.paqueteria],
        instalaciones: [],
        adminIds: ['2'],
      ),
    );

    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<SuperadminState>()
            .having(
              (s) => s.mensaje,
              'mensaje',
              'Proyecto "Proyecto editado" actualizado.',
            )
            .having((s) => s.exito, 'exito', true)
            .having((s) => s.guardando, 'guardando', false),
      ),
    );

    expect(repository.proyectoActualizadoId, '7');
  });

  test('valida el nombre vacío sin llamar al repositorio', () async {
    bloc.add(
      const ProyectoActualizado(
        id: '7',
        nombre: '   ',
        descripcion: null,
        modulos: [ModuloSistema.infraestructura],
        instalaciones: [],
        adminIds: ['2'],
      ),
    );

    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<SuperadminState>()
            .having((s) => s.exito, 'exito', false)
            .having(
              (s) => s.mensaje,
              'mensaje',
              'El nombre del proyecto es obligatorio.',
            ),
      ),
    );

    expect(repository.proyectoActualizadoId, isNull);
  });

  test('crea accesorias en lote y recarga la estructura', () async {
    bloc.add(
      const AccesoriasLoteSolicitadas(
        proyectoId: '7',
        tipo: TipoUnidadAccesoria.estacionamiento,
        cantidad: 3,
      ),
    );

    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<SuperadminState>()
            .having(
              (s) => s.mensaje,
              'mensaje',
              'Se crearon 3 estacionamientos.',
            )
            .having((s) => s.exito, 'exito', true)
            .having((s) => s.guardando, 'guardando', false),
      ),
    );

    expect(infraestructuraRepository.loteCantidad, 3);
    expect(
      infraestructuraRepository.loteTipo,
      TipoUnidadAccesoria.estacionamiento,
    );
    expect(infraestructuraRepository.loteAsignacion, isNull);
  });

  test('actualiza varias asignaciones en una sola solicitud', () async {
    bloc.add(
      const AsignacionesAccesoriasSolicitadas(
        proyectoId: '7',
        asignaciones: [
          AsignacionAccesoria(
            unidadAccesoriaId: '1',
            asignacion: TipoAsignacion.visita,
          ),
          AsignacionAccesoria(
            unidadAccesoriaId: '2',
            asignacion: TipoAsignacion.departamento,
            unidadPrincipalId: '1',
          ),
        ],
      ),
    );

    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<SuperadminState>()
            .having(
              (s) => s.mensaje,
              'mensaje',
              'Se actualizaron 2 asignaciones.',
            )
            .having((s) => s.exito, 'exito', true),
      ),
    );

    expect(infraestructuraRepository.asignacionesRecibidas, hasLength(2));
    expect(
      infraestructuraRepository.asignacionesRecibidas.last.unidadPrincipalId,
      '1',
    );
  });

  test('carga la estructura del proyecto para el modo edición', () async {
    bloc.add(const EstructuraProyectoSolicitada('7'));

    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<SuperadminState>()
            .having((s) => s.cargandoEstructura, 'cargandoEstructura', false)
            .having((s) => s.estructura?.agrupaciones.length, 'agrupaciones', 1)
            .having(
              (s) => s
                  .estructura
                  ?.agrupaciones
                  .first
                  .unidadesPrincipales
                  .first
                  .unidadesAccesorias
                  .length,
              'accesorias',
              1,
            ),
      ),
    );
  });

  test('expone el error de estructura sin bloquear el formulario', () async {
    infraestructuraRepository.failure = const ServerFailure(
      'No se pudo cargar la estructura.',
    );

    bloc.add(const EstructuraProyectoSolicitada('7'));

    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<SuperadminState>()
            .having((s) => s.cargandoEstructura, 'cargandoEstructura', false)
            .having((s) => s.estructura, 'estructura', isNull)
            .having(
              (s) => s.errorEstructura,
              'errorEstructura',
              'No se pudo cargar la estructura.',
            ),
      ),
    );
  });
}
