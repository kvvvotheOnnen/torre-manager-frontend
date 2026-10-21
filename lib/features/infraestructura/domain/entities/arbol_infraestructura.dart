import 'package:equatable/equatable.dart';

import 'agrupacion.dart';
import 'proyecto.dart';
import 'unidad_accesoria.dart';
import 'unidad_principal.dart';

class ArbolUnidadPrincipal extends Equatable {
  const ArbolUnidadPrincipal({
    required this.unidadPrincipal,
    required this.unidadesAccesorias,
  });

  final UnidadPrincipal unidadPrincipal;
  final List<UnidadAccesoria> unidadesAccesorias;

  @override
  List<Object?> get props => [unidadPrincipal, unidadesAccesorias];
}

class ArbolAgrupacion extends Equatable {
  const ArbolAgrupacion({required this.agrupacion, required this.unidadesPrincipales});

  final Agrupacion agrupacion;
  final List<ArbolUnidadPrincipal> unidadesPrincipales;

  @override
  List<Object?> get props => [agrupacion, unidadesPrincipales];
}

class ArbolInfraestructura extends Equatable {
  const ArbolInfraestructura({required this.proyecto, required this.agrupaciones});

  final Proyecto proyecto;
  final List<ArbolAgrupacion> agrupaciones;

  @override
  List<Object?> get props => [proyecto, agrupaciones];
}
