import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/registro_residente.dart';
import '../repositories/registro_residente_repository.dart';

class ListarProyectosRegistroUseCase {
  const ListarProyectosRegistroUseCase(this._repository);

  final RegistroResidenteRepository _repository;

  Future<Either<Failure, List<ProyectoRegistro>>> call() =>
      _repository.listarProyectos();
}
