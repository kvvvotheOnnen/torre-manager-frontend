import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/tipo_servicio.dart';
import '../entities/trabajador_servicio.dart';
import '../entities/trabajador_servicio_foto.dart';
import '../repositories/servicios_repository.dart';

class CrearTrabajadorUseCase {
  const CrearTrabajadorUseCase(this._repository);

  final ServiciosRepositoryInterface _repository;

  Future<Either<Failure, TrabajadorServicio>> call({
    required String nombre,
    String? nombreEmpresa,
    required String telefono,
    required TipoServicio tipo,
    String? descripcion,
    TrabajadorServicioFoto? foto,
  }) {
    return _repository.crear(
      nombre: nombre,
      nombreEmpresa: nombreEmpresa,
      telefono: telefono,
      tipo: tipo,
      descripcion: descripcion,
      foto: foto,
    );
  }
}
