import '../../domain/entities/arbol_infraestructura.dart';
import 'agrupacion_dto.dart';
import 'proyecto_dto.dart';
import 'unidad_accesoria_dto.dart';
import 'unidad_principal_dto.dart';

class ArbolInfraestructuraDTO {
  const ArbolInfraestructuraDTO({
    required this.proyecto,
    required this.agrupaciones,
    required this.unidadesAccesorias,
  });

  final ProyectoDTO proyecto;
  final List<AgrupacionConUnidadesDTO> agrupaciones;
  final List<UnidadAccesoriaDTO> unidadesAccesorias;

  factory ArbolInfraestructuraDTO.fromJson(Map<String, dynamic> json) {
    return ArbolInfraestructuraDTO(
      proyecto: ProyectoDTO.fromJson(
        (json['proyecto'] ?? const <String, dynamic>{}) as Map<String, dynamic>,
      ),
      agrupaciones: ((json['agrupaciones'] ?? const []) as List)
          .map((item) => AgrupacionConUnidadesDTO.fromJson(
                (item as Map<String, dynamic>),
              ))
          .toList(),
      unidadesAccesorias: ((json['unidades_accesorias'] ?? const []) as List)
          .map((item) => UnidadAccesoriaDTO.fromJson(
                (item as Map<String, dynamic>),
              ))
          .toList(),
    );
  }

  ArbolInfraestructura toEntity() {
    return ArbolInfraestructura(
      proyecto: proyecto.toEntity(),
      agrupaciones: agrupaciones.map((item) => item.toEntity()).toList(),
      unidadesAccesorias: unidadesAccesorias.map((item) => item.toEntity()).toList(),
    );
  }
}

class AgrupacionConUnidadesDTO {
  const AgrupacionConUnidadesDTO({
    required this.agrupacion,
    required this.unidadesPrincipales,
  });

  final AgrupacionDTO agrupacion;
  final List<UnidadPrincipalConAccesoriasDTO> unidadesPrincipales;

  factory AgrupacionConUnidadesDTO.fromJson(Map<String, dynamic> json) {
    return AgrupacionConUnidadesDTO(
      agrupacion: AgrupacionDTO.fromJson(json),
      unidadesPrincipales: ((json['unidades_principales'] ?? const []) as List)
          .map((item) => UnidadPrincipalConAccesoriasDTO.fromJson(
                (item as Map<String, dynamic>),
              ))
          .toList(),
    );
  }

  ArbolAgrupacion toEntity() {
    return ArbolAgrupacion(
      agrupacion: agrupacion.toEntity(),
      unidadesPrincipales: unidadesPrincipales.map((item) => item.toEntity()).toList(),
    );
  }
}

class UnidadPrincipalConAccesoriasDTO {
  const UnidadPrincipalConAccesoriasDTO({
    required this.unidadPrincipal,
    required this.unidadesAccesorias,
  });

  final UnidadPrincipalDTO unidadPrincipal;
  final List<UnidadAccesoriaDTO> unidadesAccesorias;

  factory UnidadPrincipalConAccesoriasDTO.fromJson(Map<String, dynamic> json) {
    return UnidadPrincipalConAccesoriasDTO(
      unidadPrincipal: UnidadPrincipalDTO.fromJson(json),
      unidadesAccesorias: ((json['unidades_accesorias'] ?? const []) as List)
          .map((item) => UnidadAccesoriaDTO.fromJson(
                (item as Map<String, dynamic>),
              ))
          .toList(),
    );
  }

  ArbolUnidadPrincipal toEntity() {
    return ArbolUnidadPrincipal(
      unidadPrincipal: unidadPrincipal.toEntity(),
      unidadesAccesorias: unidadesAccesorias.map((item) => item.toEntity()).toList(),
    );
  }
}
