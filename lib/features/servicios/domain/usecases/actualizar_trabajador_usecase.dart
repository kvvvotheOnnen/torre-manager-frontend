import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/tipo_servicio.dart';
import '../entities/trabajador_servicio.dart';
import '../entities/trabajador_servicio_foto.dart';
import '../repositories/servicios_repository.dart';

class ActualizarTrabajadorUseCase {
  const ActualizarTrabajadorUseCase(this._repository);

  final ServiciosRepositoryInterface _repository;

  Future<Either<Failure, TrabajadorServicio>> call({
    required String id,
    required String nombre,
    String? nombreEmpresa,
    required String telefono,
    required TipoServicio tipo,
    String? descripcion,
    TrabajadorServicioFoto? foto,
  }) {
    return _repository.actualizar(
      id: id,
      nombre: nombre,
      nombreEmpresa: nombreEmpresa,
      telefono: telefono,
      tipo: tipo,
      descripcion: descripcion,
      foto: foto,
    );
  }
}
