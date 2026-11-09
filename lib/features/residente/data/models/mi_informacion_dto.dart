import '../../domain/entities/mi_informacion.dart';

class MiInformacionDto {
  const MiInformacionDto({required this.unidad, required this.agrupacion});

  final String unidad;
  final String agrupacion;

  factory MiInformacionDto.fromJson(Map<String, dynamic> json) {
    return MiInformacionDto(
      unidad: (json['unidad'] ?? '') as String,
      agrupacion: (json['agrupacion'] ?? '') as String,
    );
  }

  MiInformacion toEntity() {
    return MiInformacion(unidad: unidad, agrupacion: agrupacion);
  }
}
