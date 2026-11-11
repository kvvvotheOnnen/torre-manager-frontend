import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:torre_manager_frontend/core/errors/failures.dart';
import 'package:torre_manager_frontend/features/asistente/domain/entities/documento_asistente.dart';
import 'package:torre_manager_frontend/features/asistente/domain/repositories/asistente_admin_repository.dart';
import 'package:torre_manager_frontend/features/asistente/domain/usecases/eliminar_documento_use_case.dart';
import 'package:torre_manager_frontend/features/asistente/domain/usecases/obtener_documento_use_case.dart';
import 'package:torre_manager_frontend/features/asistente/domain/usecases/subir_documento_use_case.dart';
import 'package:torre_manager_frontend/features/asistente/presentation/bloc/asistente_admin_bloc.dart';

class _FakeAsistenteAdminRepository implements AsistenteAdminRepositoryInterface {
  _FakeAsistenteAdminRepository({
    this._documento,
    this.fallaSubida,
  });

  DocumentoAsistente? _documento;
  final Failure? fallaSubida;

  @override
  Future<Either<Failure, DocumentoAsistente?>> obtenerDocumento() async {
    return Right(_documento);
  }

  @override
  Future<Either<Failure, DocumentoAsistente>> subirDocumento({
    required List<int> bytes,
    required String nombre,
  }) async {
    if (fallaSubida != null) {
      return Left(fallaSubida!);
    }

    _documento = DocumentoAsistente(
      id: '1',
      nombre: nombre,
      paginas: 2,
      tamanoTokens: 900,
    );

    return Right(_documento!);
  }

  @override
  Future<Either<Failure, void>> eliminarDocumento() async {
    _documento = null;
    return const Right(null);
  }
}

AsistenteAdminBloc _crearBloc(_FakeAsistenteAdminRepository repository) {
  return AsistenteAdminBloc(
    obtenerDocumentoUseCase: ObtenerDocumentoUseCase(repository),
    subirDocumentoUseCase: SubirDocumentoUseCase(repository),
    eliminarDocumentoUseCase: EliminarDocumentoUseCase(repository),
  );
}

void main() {
  test('carga el documento actual del proyecto', () async {
    final bloque = _crearBloc(
      _FakeAsistenteAdminRepository(
        documento: const DocumentoAsistente(
          id: '1',
          nombre: 'reglamento.pdf',
          paginas: 2,
          tamanoTokens: 900,
        ),
      ),
    );

    final esperado = expectLater(
      bloque.stream,
      emitsThrough(
        predicate<AsistenteAdminState>(
          (state) =>
              state.status == AsistenteAdminStatus.cargado &&
              state.documento?.nombre == 'reglamento.pdf',
        ),
      ),
    );

    bloque.add(const AsistenteAdminDocumentoSolicitado());
    await esperado;
    await bloque.close();
  });

  test('sube un documento y actualiza el estado', () async {
    final bloque = _crearBloc(_FakeAsistenteAdminRepository());

    final esperado = expectLater(
      bloque.stream,
      emitsThrough(
        predicate<AsistenteAdminState>(
          (state) =>
              state.status == AsistenteAdminStatus.cargado &&
              state.documento?.nombre == 'nuevo.pdf',
        ),
      ),
    );

    bloque.add(
      const AsistenteAdminDocumentoSubido(
        bytes: [1, 2, 3],
        nombre: 'nuevo.pdf',
      ),
    );
    await esperado;
    await bloque.close();
  });

  test('al fallar la subida notifica el mensaje', () async {
    final bloque = _crearBloc(
      _FakeAsistenteAdminRepository(
        fallaSubida: const ValidationFailure('El documento es demasiado grande.'),
      ),
    );

    final esperado = expectLater(
      bloque.stream,
      emitsThrough(
        predicate<AsistenteAdminState>(
          (state) => state.mensaje == 'El documento es demasiado grande.',
        ),
      ),
    );

    bloque.add(
      const AsistenteAdminDocumentoSubido(bytes: [1], nombre: 'grande.pdf'),
    );
    await esperado;
    await bloque.close();
  });

  test('elimina el documento y deja el estado vacío', () async {
    final bloque = _crearBloc(
      _FakeAsistenteAdminRepository(
        documento: const DocumentoAsistente(
          id: '1',
          nombre: 'reglamento.pdf',
          paginas: 2,
          tamanoTokens: 900,
        ),
      ),
    );

    bloque.add(const AsistenteAdminDocumentoSolicitado());
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final esperado = expectLater(
      bloque.stream,
      emitsThrough(
        predicate<AsistenteAdminState>(
          (state) =>
              state.status == AsistenteAdminStatus.cargado &&
              state.documento == null,
        ),
      ),
    );

    bloque.add(const AsistenteAdminDocumentoEliminado());
    await esperado;
    await bloque.close();
  });
}
