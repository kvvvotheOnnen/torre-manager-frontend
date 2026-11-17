import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/tipo_servicio.dart';
import '../entities/trabajador_servicio.dart';
import '../entities/trabajador_servicio_foto.dart';

abstract interface class ServiciosRepositoryInterface {
  Future<Either<Failure, List<TrabajadorServicio>>> listar({
    TipoServicio? tipo,
    String? buscar,
  });

  Future<Either<Failure, TrabajadorServicio>> crear({
    required String nombre,
    String? nombreEmpresa,
    required String telefono,
    required TipoServicio tipo,
    String? descripcion,
    TrabajadorServicioFoto? foto,
  });

  Future<Either<Failure, TrabajadorServicio>> actualizar({
    required String id,
    required String nombre,
    String? nombreEmpresa,
    required String telefono,
    required TipoServicio tipo,
    String? descripcion,
    TrabajadorServicioFoto? foto,
  });

  Future<Either<Failure, bool>> eliminar(String id);
}
