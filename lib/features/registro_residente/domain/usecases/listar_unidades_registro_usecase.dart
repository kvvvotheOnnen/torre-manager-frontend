import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/registro_residente.dart';
import '../repositories/registro_residente_repository.dart';

class ListarUnidadesRegistroUseCase {
  const ListarUnidadesRegistroUseCase(this._repository);

  final RegistroResidenteRepository _repository;

  Future<Either<Failure, List<UnidadRegistro>>> call(String proyectoId) =>
      _repository.listarUnidades(proyectoId);
}
