import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/core/errors/failures.dart';
import 'package:torre_manager_frontend/features/infraestructura/domain/entities/tipo_agrupacion.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/entities/administrador.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/entities/definicion_agrupacion.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/entities/instalacion_extra.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/entities/modulo_sistema.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/entities/proyecto_detalle.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/entities/resumen_proyecto.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/entities/tipo_condominio.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/repositories/superadmin_repository.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/usecases/descartar_proyecto_borrador_usecase.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/usecases/guardar_paso_proyecto_usecase.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/usecases/iniciar_proyecto_borrador_usecase.dart';
import 'package:torre_manager_frontend/features/superadmin/presentation/bloc/proyecto_wizard_bloc.dart';
import 'package:torre_manager_frontend/features/superadmin/presentation/bloc/proyecto_wizard_event.dart';

class _FakeRepositorio implements SuperadminRepositoryInterface {
  Failure? iniciarFailure;
  Failure? guardarFailure;
  String? borradorDescartadoId;
  bool finalizado = false;
  String? ultimoBorradorId;

  ProyectoDetalle _detalle({String id = '1', String nombre = 'Proyecto'}) {
    return ProyectoDetalle(
      id: id,
      nombre: nombre,
      descripcion: null,
      tipoCondominio: TipoCondominio.torres,
      modulos: const [ModuloSistema.infraestructura],
      instalacionesExtra: const [],
      adminIds: const ['2'],
    );
  }

  @override
  Future<Either<Failure, ProyectoDetalle>> iniciarProyectoBorrador({
    required String nombre,
    String? descripcion,
  }) async {
    final failure = iniciarFailure;
    if (failure != null) return Left(failure);

    return Right(_detalle(nombre: nombre));
  }

  @override
  Future<Either<Failure, ProyectoDetalle>> guardarPasoProyecto({
    required String id,
    required String nombre,
    String? descripcion,
    TipoCondominio? tipoCondominio,
    List<DefinicionAgrupacion>? agrupaciones,
    List<InstalacionExtra>? instalaciones,
    List<ModuloSistema>? modulos,
    List<String>? adminIds,
    bool resetEstructura = false,
    bool finalizar = false,
  }) async {
    final failure = guardarFailure;
    if (failure != null) return Left(failure);

    ultimoBorradorId = id;
    if (finalizar) finalizado = true;

    return Right(_detalle(id: id, nombre: nombre));
  }

  @override
  Future<Either<Failure, void>> descartarProyectoBorrador(String id) async {
    borradorDescartadoId = id;
    return const Right(null);
  }

  @override
  Future<Either<Failure, ProyectoDetalle>> obtenerProyecto(String id) async {
    return Right(_detalle(id: id));
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
    return Right(_detalle(id: id, nombre: nombre));
  }

  @override
  Future<Either<Failure, void>> eliminarProyecto(String id) async {
    return const Right(null);
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
    return Right(Administrador(id: '1', nombre: nombre, correo: correo));
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
    return Right(_detalle(nombre: nombre));
  }

  @override
  Future<Either<Failure, List<ProyectoDetalle>>> listarMisProyectos() async {
    return const Right([]);
  }
}

void main() {
  late _FakeRepositorio repositorio;
  late ProyectoWizardBloc bloc;

  setUp(() {
    repositorio = _FakeRepositorio();
    bloc = ProyectoWizardBloc(
      iniciarProyectoBorradorUseCase: IniciarProyectoBorradorUseCase(
        repositorio,
      ),
      guardarPasoProyectoUseCase: GuardarPasoProyectoUseCase(repositorio),
      descartarProyectoBorradorUseCase: DescartarProyectoBorradorUseCase(
        repositorio,
      ),
    );
  });

  tearDown(() => bloc.close());

  test('inicia el borrador y avanza al paso de tipo', () async {
    final future = bloc.stream.firstWhere(
      (s) => s.pasoActual == 1 && !s.guardando,
    );
    bloc.add(const WizardIniciado(nombre: 'Proyecto nuevo'));

    final state = await future;

    expect(state.proyectoId, '1');
    expect(state.nombre, 'Proyecto nuevo');
  });

  test('no avanza si falla el inicio del borrador', () async {
    repositorio.iniciarFailure = const ValidationFailure('Nombre inválido');

    final future = bloc.stream.firstWhere(
      (s) => !s.guardando && s.mensaje != null,
    );
    bloc.add(const WizardIniciado(nombre: 'Proyecto con error'));

    final state = await future;

    expect(state.pasoActual, 0);
    expect(state.mensaje, 'Nombre inválido');
    expect(state.mensajeEsError, isTrue);
  });

  test('guarda tipo y estructura avanzando de paso', () async {
    final inicio = bloc.stream.firstWhere(
      (s) => s.pasoActual == 1 && !s.guardando,
    );
    bloc.add(const WizardIniciado(nombre: 'Proyecto'));
    await inicio;

    final trasTipoFuture = bloc.stream.firstWhere(
      (s) => s.pasoActual == 2 && !s.guardando,
    );
    bloc.add(const WizardTipoGuardado(TipoCondominio.torres));
    final trasTipo = await trasTipoFuture;
    expect(trasTipo.tipoConfirmado, TipoCondominio.torres);

    final trasEstructuraFuture = bloc.stream.firstWhere(
      (s) => s.pasoActual == 3 && !s.guardando,
    );
    bloc.add(
      const WizardEstructuraGuardada([
        DefinicionAgrupacion(
          nombre: 'Torre A',
          tipo: TipoAgrupacion.torre,
          pisoDesde: 1,
          pisoHasta: 1,
          unidadesPorPiso: 2,
        ),
      ]),
    );

    final trasEstructura = await trasEstructuraFuture;

    expect(trasEstructura.pasoActual, 3);
    expect(repositorio.ultimoBorradorId, '1');
  });

  test('descarta el borrador y reinicia el asistente', () async {
    final inicio = bloc.stream.firstWhere(
      (s) => s.pasoActual == 1 && !s.guardando,
    );
    bloc.add(const WizardIniciado(nombre: 'Proyecto'));
    await inicio;

    final future = bloc.stream.firstWhere(
      (s) => !s.descartando && s.proyectoId == null,
    );
    bloc.add(const WizardDescartado());

    final state = await future;

    expect(repositorio.borradorDescartadoId, '1');
    expect(state.pasoActual, 0);
  });

  test('finaliza el proyecto con módulos y administradores', () async {
    final inicio = bloc.stream.firstWhere(
      (s) => s.pasoActual == 1 && !s.guardando,
    );
    bloc.add(const WizardIniciado(nombre: 'Proyecto'));
    await inicio;

    final future = bloc.stream.firstWhere((s) => s.finalizado);
    bloc.add(const WizardFinalizado([ModuloSistema.infraestructura], ['2']));

    final state = await future;

    expect(state.finalizado, isTrue);
    expect(repositorio.finalizado, isTrue);
  });
}
