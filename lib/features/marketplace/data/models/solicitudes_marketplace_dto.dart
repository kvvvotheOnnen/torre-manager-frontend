import '../../domain/entities/solicitudes_marketplace.dart';
import 'publicacion_marketplace_dto.dart';

class SolicitudesMarketplaceDto {
  const SolicitudesMarketplaceDto({
    required this.pendientes,
    required this.solicitudes,
  });

  factory SolicitudesMarketplaceDto.fromJson(Map<String, dynamic> json) {
    final pendientes = json['pendientes'];
    final items = json['solicitudes'] as List<dynamic>? ?? const [];

    return SolicitudesMarketplaceDto(
      pendientes: pendientes is num ? pendientes.toInt() : 0,
      solicitudes: items
          .whereType<Map>()
          .map(
            (item) => PublicacionMarketplaceDto.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }

  final int pendientes;
  final List<PublicacionMarketplaceDto> solicitudes;

  SolicitudesMarketplace toEntity() => SolicitudesMarketplace(
    pendientes: pendientes,
    solicitudes: solicitudes.map((dto) => dto.toEntity()).toList(),
  );
}
