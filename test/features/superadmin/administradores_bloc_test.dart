import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:torre_manager_frontend/core/errors/failures.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/entities/administrador.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/repositories/superadmin_repository.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/usecases/crear_administrador_usecase.dart';
import 'package:torre_manager_frontend/features/superadmin/domain/usecases/listar_administradores_usecase.dart';
import 'package:torre_manager_frontend/features/superadmin/presentation/bloc/administradores_bloc.dart';

class _FakeRepositorio implements SuperadminRepositoryInterface {
  List<String>? ultimosProyectosIds;

  @override
  Future<Either<Failure, List<Administrador>>> listarAdministradores() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Administrador>> crearAdministrador({
    required String nombre,
    required String correo,
    required String password,
    List<String>? proyectoIds,
  }) async {
    ultimosProyectosIds = proyectoIds;

    return Right(
      Administrador(id: '1', nombre: nombre, correo: correo),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  test('propaga los proyectos seleccionados al crear el administrador', () async {
    final repositorio = _FakeRepositorio();
    final bloc = AdministradoresBloc(
      listarAdministradoresUseCase: ListarAdministradoresUseCase(repositorio),
      crearAdministradorUseCase: CrearAdministradorUseCase(repositorio),
    );
    addTearDown(bloc.close);

    final future = bloc.stream.firstWhere((state) => state.exito);
    bloc.add(
      const AdministradorCreado(
        nombre: 'Admin Demo',
        correo: 'admin@example.test',
        password: 'password123',
        proyectoIds: ['1', '2'],
      ),
    );

    await future;

    expect(repositorio.ultimosProyectosIds, ['1', '2']);
  });
}
