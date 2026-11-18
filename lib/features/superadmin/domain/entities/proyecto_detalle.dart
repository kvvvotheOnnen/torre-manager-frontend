import 'package:equatable/equatable.dart';

import 'instalacion_extra.dart';
import 'modulo_general.dart';
import 'modulo_sistema.dart';
import 'tipo_condominio.dart';

class ProyectoDetalle extends Equatable {
  const ProyectoDetalle({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.tipoCondominio,
    required this.modulos,
    required this.instalacionesExtra,
    required this.adminIds,
    this.modulosDeshabilitados = const [],
    this.rol,
  });

  final String id;
  final String nombre;
  final String? descripcion;
  final TipoCondominio tipoCondominio;
  final List<ModuloSistema> modulos;
  final List<InstalacionExtra> instalacionesExtra;
  final List<String> adminIds;
  final List<ModuloGeneral> modulosDeshabilitados;
  final String? rol;

  @override
  List<Object?> get props => [
    id,
    nombre,
    descripcion,
    tipoCondominio,
    modulos,
    instalacionesExtra,
    adminIds,
    modulosDeshabilitados,
    rol,
  ];
}
