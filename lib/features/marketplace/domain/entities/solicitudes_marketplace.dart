import 'package:equatable/equatable.dart';

import 'publicacion_marketplace.dart';

class SolicitudesMarketplace extends Equatable {
  const SolicitudesMarketplace({
    required this.pendientes,
    required this.solicitudes,
  });

  final int pendientes;
  final List<PublicacionMarketplace> solicitudes;

  @override
  List<Object?> get props => [pendientes, solicitudes];
}
