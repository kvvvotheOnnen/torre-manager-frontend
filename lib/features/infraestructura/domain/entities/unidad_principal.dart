import 'package:equatable/equatable.dart';

class UnidadPrincipal extends Equatable {
  const UnidadPrincipal({
    required this.id,
    required this.agrupacionId,
    required this.identificador,
  });

  final String id;
  final String agrupacionId;
  final String identificador;

  @override
  List<Object?> get props => [id, agrupacionId, identificador];
}
