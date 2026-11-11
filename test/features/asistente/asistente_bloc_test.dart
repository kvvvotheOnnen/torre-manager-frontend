import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:torre_manager_frontend/core/errors/failures.dart';
import 'package:torre_manager_frontend/features/asistente/domain/entities/fuente_asistente.dart';
import 'package:torre_manager_frontend/features/asistente/domain/entities/respuesta_asistente.dart';
import 'package:torre_manager_frontend/features/asistente/domain/repositories/asistente_repository.dart';
import 'package:torre_manager_frontend/features/asistente/domain/usecases/consultar_asistente_use_case.dart';
import 'package:torre_manager_frontend/features/asistente/presentation/bloc/asistente_bloc.dart';

class _FakeAsistenteRepository implements AsistenteRepositoryInterface {
  _FakeAsistenteRepository(this._resultado);

  final Either<Failure, RespuestaAsistente> _resultado;

  @override
  Future<Either<Failure, RespuestaAsistente>> consultar(String pregunta) async {
    return _resultado;
  }
}

void main() {
  test('agrega la pregunta y la respuesta con fuentes', () async {
    final bloque = AsistenteBloc(
      consultarUseCase: ConsultarAsistenteUseCase(
        _FakeAsistenteRepository(
          const Right(
            RespuestaAsistente(
              respuesta: 'El quincho está en el piso 7 [Página 1].',
              fuentes: [FuenteAsistente(documento: 'reglamento.pdf', pagina: 1)],
            ),
          ),
        ),
      ),
    );

    final esperado = expectLater(
      bloque.stream,
      emitsThrough(
        predicate<AsistenteState>(
          (state) =>
              state.status == AsistenteStatus.respondido &&
              state.mensajes.length == 2 &&
              !state.mensajes.last.esUsuario &&
              state.mensajes.last.fuentes.single.pagina == 1,
        ),
      ),
    );

    bloque.add(const AsistentePreguntaEnviada('¿Dónde está el quincho?'));
    await esperado;
    await bloque.close();
  });

  test('ante un fallo conserva la pregunta y expone el mensaje de error', () async {
    final bloque = AsistenteBloc(
      consultarUseCase: ConsultarAsistenteUseCase(
        _FakeAsistenteRepository(
          const Left(ServerFailure('La administración no ha cargado un documento.')),
        ),
      ),
    );

    final esperado = expectLater(
      bloque.stream,
      emitsThrough(
        predicate<AsistenteState>(
          (state) =>
              state.status == AsistenteStatus.error &&
              state.mensajes.length == 1 &&
              state.mensajeError != null,
        ),
      ),
    );

    bloque.add(const AsistentePreguntaEnviada('¿Dónde está el quincho?'));
    await esperado;
    await bloque.close();
  });
}
