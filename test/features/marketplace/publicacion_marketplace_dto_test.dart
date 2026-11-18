import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/features/marketplace/data/models/publicacion_marketplace_dto.dart';
import 'package:torre_manager_frontend/features/marketplace/domain/entities/categoria_producto.dart';
import 'package:torre_manager_frontend/features/marketplace/domain/entities/condicion_producto.dart';
import 'package:torre_manager_frontend/features/marketplace/domain/entities/estado_publicacion.dart';

void main() {
  test('mapea una publicación completa del backend', () {
    final dto = PublicacionMarketplaceDto.fromJson({
      'id': 7,
      'titulo': 'Refrigerador',
      'descripcion': 'Funciona perfecto.',
      'precio': 150000,
      'categoria': 'electrodomesticos',
      'categoria_etiqueta': 'Electrodomésticos',
      'condicion': 'semi_nuevo',
      'condicion_etiqueta': 'Semi nuevo',
      'estado': 'vendida',
      'estado_etiqueta': 'Vendida',
      'foto_url': 'https://example.com/foto.jpg',
      'es_mia': true,
      'es_favorita': false,
      'puede_editar': false,
      'puede_eliminar': true,
      'puede_retirar': false,
      'puede_marcar_vendida': false,
      'contacto_disponible': false,
      'vendido_en': '2026-11-17T10:30:00Z',
      'motivo_eliminacion': null,
      'eliminado_por_rol': null,
      'eliminado_en': null,
      'creado_en': '2026-11-16T08:00:00Z',
    });

    final publicacion = dto.toEntity();

    expect(publicacion.id, '7');
    expect(publicacion.titulo, 'Refrigerador');
    expect(publicacion.precio, 150000);
    expect(publicacion.categoria, CategoriaProducto.electrodomesticos);
    expect(publicacion.condicion, CondicionProducto.semiNuevo);
    expect(publicacion.estado, EstadoPublicacion.vendida);
    expect(publicacion.fotoUrl, 'https://example.com/foto.jpg');
    expect(publicacion.esMia, isTrue);
    expect(publicacion.puedeEliminar, isTrue);
    expect(publicacion.vendidoEn, isNotNull);
    expect(publicacion.tieneFoto, isTrue);
  });

  test('tolera enums desconocidos, nulos y precio como texto', () {
    final dto = PublicacionMarketplaceDto.fromJson({
      'id': '9',
      'titulo': 'Mesa',
      'descripcion': '',
      'precio': '2500',
      'categoria': 'jardín',
      'condicion': 'usado',
      'estado': 'archivada',
      'foto_url': '',
      'motivo_eliminacion': '',
    });

    final publicacion = dto.toEntity();

    expect(publicacion.precio, 2500);
    expect(publicacion.categoria, CategoriaProducto.otros);
    expect(publicacion.estado, EstadoPublicacion.desconocido);
    expect(publicacion.fotoUrl, isNull);
    expect(publicacion.motivoEliminacion, isNull);
    expect(publicacion.tieneFoto, isFalse);
  });
}
