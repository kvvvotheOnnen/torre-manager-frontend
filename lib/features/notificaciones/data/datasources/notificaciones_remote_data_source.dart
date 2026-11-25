import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../models/notificacion_dto.dart';

class NotificacionesRemoteDataSource {
  const NotificacionesRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<NotificacionDto>> listar() async {
    final response = await _client.get<Map<String, dynamic>>(
      AppConfig.notificacionesPath,
    );
    final items =
        response.data?['notificaciones'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map>()
        .map((item) => NotificacionDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<int> contarNoLeidas() async {
    final response = await _client.get<Map<String, dynamic>>(
      AppConfig.notificacionesNoLeidasPath,
    );
    final valor = response.data?['no_leidas'];
    if (valor is! num) {
      throw const FormatException('Respuesta inesperada del servidor.');
    }
    return valor.toInt();
  }

  Future<NotificacionDto> marcarLeida(String id) async {
    final response = await _client.patch<Map<String, dynamic>>(
      AppConfig.notificacionLeerPath(id),
    );
    return _leer(response.data);
  }

  Future<int> marcarTodasLeidas() async {
    final response = await _client.patch<Map<String, dynamic>>(
      AppConfig.notificacionesLeerTodasPath,
    );
    final valor = response.data?['marcadas'];
    if (valor is! num) {
      throw const FormatException('Respuesta inesperada del servidor.');
    }
    return valor.toInt();
  }

  NotificacionDto _leer(Map<String, dynamic>? data) {
    final item = data?['notificacion'];
    if (item is! Map) {
      throw const FormatException('Respuesta inesperada del servidor.');
    }
    return NotificacionDto.fromJson(Map<String, dynamic>.from(item));
  }
}
