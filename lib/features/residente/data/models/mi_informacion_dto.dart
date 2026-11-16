import '../../domain/entities/mi_informacion.dart';

class MiInformacionDto {
  const MiInformacionDto({required this.unidades});

  final List<UnidadVinculada> unidades;

  factory MiInformacionDto.fromJson(Map<String, dynamic> json) {
    final lista = (json['unidades'] ?? const []) as List;

    if (lista.isNotEmpty) {
      return MiInformacionDto(
        unidades: lista
            .map((item) {
              final data = item as Map<String, dynamic>;
              return UnidadVinculada(
                unidad: (data['unidad'] ?? '') as String,
                agrupacion: (data['agrupacion'] ?? '') as String,
                proyectoId: '${data['proyecto_id'] ?? ''}',
                tipoVinculo: (data['tipo_vinculo'] ?? 'residente') as String,
                esActual: (data['es_actual'] ?? false) as bool,
                fechaInicio: data['fecha_inicio'] as String?,
                fechaFin: data['fecha_fin'] as String?,
              );
            })
            .toList(),
      );
    }

    // Compatibilidad con la respuesta antigua de una sola unidad.
    return MiInformacionDto(
      unidades: [
        UnidadVinculada(
          unidad: (json['unidad'] ?? '') as String,
          agrupacion: (json['agrupacion'] ?? '') as String,
          proyectoId: '',
          tipoVinculo: 'residente',
          esActual: true,
        ),
      ],
    );
  }

  MiInformacion toEntity() {
    return MiInformacion(unidades: unidades);
  }
}
