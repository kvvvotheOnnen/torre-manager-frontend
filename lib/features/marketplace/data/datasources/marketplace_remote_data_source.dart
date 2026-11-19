import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';

import '../../../../core/config/app_config.dart';
import '../../domain/entities/categoria_producto.dart';
import '../../domain/entities/condicion_producto.dart';
import '../../domain/entities/estado_publicacion.dart';
import '../../domain/entities/publicacion_foto.dart';
import '../models/publicacion_marketplace_dto.dart';

class MarketplaceRemoteDataSource {
  const MarketplaceRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<PublicacionMarketplaceDto>> listar({
    bool todas = false,
    EstadoPublicacion? estado,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      AppConfig.marketplacePublicacionesPath,
      queryParameters: {
        if (estado != null) 'estado': estado.valor,
        if (estado == null && todas) 'estado': 'todas',
      },
    );
    return _leerLista(response.data);
  }

  Future<List<PublicacionMarketplaceDto>> misPublicaciones() async {
    final response = await _client.get<Map<String, dynamic>>(
      AppConfig.marketplaceMisPublicacionesPath,
    );
    return _leerLista(response.data);
  }

  Future<List<PublicacionMarketplaceDto>> historial() async {
    final response = await _client.get<Map<String, dynamic>>(
      AppConfig.marketplaceHistorialPath,
    );
    return _leerLista(response.data);
  }

  Future<List<PublicacionMarketplaceDto>> favoritos() async {
    final response = await _client.get<Map<String, dynamic>>(
      AppConfig.marketplaceFavoritosPath,
    );
    return _leerLista(response.data);
  }

  Future<PublicacionMarketplaceDto> crear({
    required String titulo,
    required String descripcion,
    required int precio,
    required CategoriaProducto categoria,
    required CondicionProducto condicion,
    PublicacionFoto? foto,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      AppConfig.marketplacePublicacionesPath,
      data: _formulario(
        titulo: titulo,
        descripcion: descripcion,
        precio: precio,
        categoria: categoria,
        condicion: condicion,
        foto: foto,
      ),
    );
    return _leerPublicacion(response.data);
  }

  Future<PublicacionMarketplaceDto> actualizar({
    required String id,
    required String titulo,
    required String descripcion,
    required int precio,
    required CategoriaProducto categoria,
    required CondicionProducto condicion,
    PublicacionFoto? foto,
  }) async {
    final response = await _client.put<Map<String, dynamic>>(
      AppConfig.marketplacePublicacionPath(id),
      data: _formulario(
        titulo: titulo,
        descripcion: descripcion,
        precio: precio,
        categoria: categoria,
        condicion: condicion,
        foto: foto,
      ),
    );
    return _leerPublicacion(response.data);
  }

  Future<PublicacionMarketplaceDto> retirar(String id) async {
    final response = await _client.post<Map<String, dynamic>>(
      AppConfig.marketplaceRetirarPath(id),
    );
    return _leerPublicacion(response.data);
  }

  Future<PublicacionMarketplaceDto> vender(String id) async {
    final response = await _client.post<Map<String, dynamic>>(
      AppConfig.marketplaceVenderPath(id),
    );
    return _leerPublicacion(response.data);
  }

  Future<void> eliminar({required String id, required String motivo}) async {
    await _client.delete<void>(
      AppConfig.marketplacePublicacionPath(id),
      data: {'motivo': motivo},
    );
  }

  Future<bool> alternarFavorito({
    required String id,
    required bool favorito,
  }) async {
    final response = await _client.put<Map<String, dynamic>>(
      AppConfig.marketplaceFavoritoPath(id),
      data: {'favorito': favorito},
    );
    return response.data?['es_favorita'] == true;
  }

  List<PublicacionMarketplaceDto> _leerLista(Map<String, dynamic>? data) {
    final items = data?['publicaciones'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map>()
        .map(
          (item) => PublicacionMarketplaceDto.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  PublicacionMarketplaceDto _leerPublicacion(Map<String, dynamic>? data) {
    final publicacion = data?['publicacion'];
    if (publicacion is! Map) {
      throw const FormatException('Respuesta inesperada del servidor.');
    }
    return PublicacionMarketplaceDto.fromJson(
      Map<String, dynamic>.from(publicacion),
    );
  }

  FormData _formulario({
    required String titulo,
    required String descripcion,
    required int precio,
    required CategoriaProducto categoria,
    required CondicionProducto condicion,
    PublicacionFoto? foto,
  }) {
    final form = FormData();
    form.fields
      ..add(MapEntry('titulo', titulo))
      ..add(MapEntry('descripcion', descripcion))
      ..add(MapEntry('precio', '$precio'))
      ..add(MapEntry('categoria', categoria.valor))
      ..add(MapEntry('condicion', condicion.valor));

    if (foto != null) {
      form.files.add(
        MapEntry(
          'foto',
          MultipartFile.fromBytes(foto.bytes, filename: foto.nombre),
        ),
      );
    }

    return form;
  }
}
