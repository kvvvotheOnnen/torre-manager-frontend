import 'package:equatable/equatable.dart';

class MiInformacion extends Equatable {
  const MiInformacion({
    required this.unidad,
    required this.agrupacion,
  });

  final String unidad;
  final String agrupacion;

  @override
  List<Object?> get props => [unidad, agrupacion];
}
