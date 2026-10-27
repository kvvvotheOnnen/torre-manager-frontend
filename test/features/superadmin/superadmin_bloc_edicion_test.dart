import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:torre_manager_frontend/core/errors/failures.dart';
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

void main() {
  late _FakeSuperadminRepository repository;
  late SuperadminBloc bloc;

  setUp(() {
    repository = _FakeSuperadminRepository();
    bloc = SuperadminBloc(
      listarProyectosUseCase: ListarProyectosUseCase(repository),
      crearProyectoUseCase: CrearProyectoUseCase(repository),
      obtenerProyectoUseCase: ObtenerProyectoUseCase(repository),
      actualizarProyectoUseCase: ActualizarProyectoUseCase(repository),
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
}
