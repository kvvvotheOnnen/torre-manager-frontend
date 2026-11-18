import 'package:equatable/equatable.dart';

import 'categoria_producto.dart';
import 'condicion_producto.dart';
import 'estado_publicacion.dart';

class PublicacionMarketplace extends Equatable {
  const PublicacionMarketplace({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.precio,
    required this.categoria,
    required this.condicion,
    required this.estado,
    required this.fotoUrl,
    required this.esMia,
    required this.esFavorita,
    required this.puedeEditar,
    required this.puedeEliminar,
    required this.puedeRetirar,
    required this.puedeMarcarVendida,
    required this.contactoDisponible,
    required this.vendidoEn,
    required this.motivoEliminacion,
    required this.eliminadoPorRol,
    required this.eliminadoEn,
    required this.creadoEn,
  });

  final String id;
  final String titulo;
  final String descripcion;
  final int precio;
  final CategoriaProducto categoria;
  final CondicionProducto condicion;
  final EstadoPublicacion estado;
  final String? fotoUrl;
  final bool esMia;
  final bool esFavorita;
  final bool puedeEditar;
  final bool puedeEliminar;
  final bool puedeRetirar;
  final bool puedeMarcarVendida;
  final bool contactoDisponible;
  final DateTime? vendidoEn;
  final String? motivoEliminacion;
  final String? eliminadoPorRol;
  final DateTime? eliminadoEn;
  final DateTime? creadoEn;

  bool get tieneFoto => fotoUrl != null && fotoUrl!.isNotEmpty;
  bool get estaDisponible => estado.estaDisponible;
  bool get estaVendida => estado.estaVendida;

  PublicacionMarketplace copyWith({bool? esFavorita}) {
    return PublicacionMarketplace(
      id: id,
      titulo: titulo,
      descripcion: descripcion,
      precio: precio,
      categoria: categoria,
      condicion: condicion,
      estado: estado,
      fotoUrl: fotoUrl,
      esMia: esMia,
      esFavorita: esFavorita ?? this.esFavorita,
      puedeEditar: puedeEditar,
      puedeEliminar: puedeEliminar,
      puedeRetirar: puedeRetirar,
      puedeMarcarVendida: puedeMarcarVendida,
      contactoDisponible: contactoDisponible,
      vendidoEn: vendidoEn,
      motivoEliminacion: motivoEliminacion,
      eliminadoPorRol: eliminadoPorRol,
      eliminadoEn: eliminadoEn,
      creadoEn: creadoEn,
    );
  }

  @override
  List<Object?> get props => [
    id,
    titulo,
    descripcion,
    precio,
    categoria,
    condicion,
    estado,
    fotoUrl,
    esMia,
    esFavorita,
    puedeEditar,
    puedeEliminar,
    puedeRetirar,
    puedeMarcarVendida,
    contactoDisponible,
    vendidoEn,
    motivoEliminacion,
    eliminadoPorRol,
    eliminadoEn,
    creadoEn,
  ];
}
