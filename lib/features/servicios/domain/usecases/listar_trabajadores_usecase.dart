import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/tipo_servicio.dart';
import '../entities/trabajador_servicio.dart';
import '../repositories/servicios_repository.dart';

class ListarTrabajadoresUseCase {
  const ListarTrabajadoresUseCase(this._repository);

  final ServiciosRepositoryInterface _repository;

  Future<Either<Failure, List<TrabajadorServicio>>> call({
    TipoServicio? tipo,
    String? buscar,
  }) {
    return _repository.listar(tipo: tipo, buscar: buscar);
  }
}
