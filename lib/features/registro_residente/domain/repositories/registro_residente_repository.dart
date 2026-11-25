import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/registro_residente.dart';

abstract interface class RegistroResidenteRepository {
  Future<Either<Failure, List<ProyectoRegistro>>> listarProyectos();

  Future<Either<Failure, List<UnidadRegistro>>> listarUnidades(
    String proyectoId,
  );

  Future<Either<Failure, String>> registrar(SolicitudRegistro solicitud);
}
