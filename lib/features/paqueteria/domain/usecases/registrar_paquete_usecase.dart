import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/paquete.dart';
import '../entities/paquete_foto.dart';
import '../repositories/paqueteria_repository.dart';

class RegistrarPaqueteUseCase {
  const RegistrarPaqueteUseCase(this._repository);

  final PaqueteriaRepositoryInterface _repository;

  Future<Either<Failure, Paquete>> call({
    required int proyectoId,
    required String descripcion,
    String? remitente,
    int? residenteId,
    int? unidadPrincipalId,
    PaqueteFoto? foto,
  }) {
    return _repository.registrar(
      proyectoId: proyectoId,
      descripcion: descripcion,
      remitente: remitente,
      residenteId: residenteId,
      unidadPrincipalId: unidadPrincipalId,
      foto: foto,
    );
  }
}
