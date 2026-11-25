import '../../domain/entities/categoria_producto.dart';
import '../../domain/entities/condicion_producto.dart';
import '../../domain/entities/estado_publicacion.dart';
import '../../domain/entities/publicacion_marketplace.dart';

class PublicacionMarketplaceDto {
  const PublicacionMarketplaceDto({
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
    required this.motivoRechazo,
    required this.rechazadoEn,
    required this.creadoEn,
  });

  factory PublicacionMarketplaceDto.fromJson(Map<String, dynamic> json) {
    return PublicacionMarketplaceDto(
      id: '${json['id'] ?? ''}',
      titulo: '${json['titulo'] ?? ''}',
      descripcion: '${json['descripcion'] ?? ''}',
      precio: _entero(json['precio']),
      categoria: categoriaProductoDesde('${json['categoria'] ?? ''}'),
      condicion: condicionProductoDesde('${json['condicion'] ?? ''}'),
      estado: estadoPublicacionDesde('${json['estado'] ?? ''}'),
      fotoUrl: _texto(json['foto_url']),
      esMia: _booleano(json['es_mia']),
      esFavorita: _booleano(json['es_favorita']),
      puedeEditar: _booleano(json['puede_editar']),
      puedeEliminar: _booleano(json['puede_eliminar']),
      puedeRetirar: _booleano(json['puede_retirar']),
      puedeMarcarVendida: _booleano(json['puede_marcar_vendida']),
      contactoDisponible: _booleano(json['contacto_disponible']),
      vendidoEn: _fecha(json['vendido_en']),
      motivoEliminacion: _texto(json['motivo_eliminacion']),
      eliminadoPorRol: _texto(json['eliminado_por_rol']),
      eliminadoEn: _fecha(json['eliminado_en']),
      motivoRechazo: _texto(json['motivo_rechazo']),
      rechazadoEn: _fecha(json['rechazado_en']),
      creadoEn: _fecha(json['creado_en']),
    );
  }

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
  final String? motivoRechazo;
  final DateTime? rechazadoEn;
  final DateTime? creadoEn;

  PublicacionMarketplace toEntity() {
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
      esFavorita: esFavorita,
      puedeEditar: puedeEditar,
      puedeEliminar: puedeEliminar,
      puedeRetirar: puedeRetirar,
      puedeMarcarVendida: puedeMarcarVendida,
      contactoDisponible: contactoDisponible,
      vendidoEn: vendidoEn,
      motivoEliminacion: motivoEliminacion,
      eliminadoPorRol: eliminadoPorRol,
      eliminadoEn: eliminadoEn,
      motivoRechazo: motivoRechazo,
      rechazadoEn: rechazadoEn,
      creadoEn: creadoEn,
    );
  }

  static String? _texto(dynamic valor) {
    if (valor == null) {
      return null;
    }
    final texto = '$valor'.trim();
    return texto.isEmpty ? null : texto;
  }

  static int _entero(dynamic valor) {
    if (valor is num) {
      return valor.toInt();
    }
    return int.tryParse('${valor ?? ''}') ?? 0;
  }

  static bool _booleano(dynamic valor) => valor == true;

  static DateTime? _fecha(dynamic valor) {
    final texto = _texto(valor);
    return texto == null ? null : DateTime.tryParse(texto);
  }
}
