import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/features/solicitudes_residente/data/models/solicitud_residente_dto.dart';
import 'package:torre_manager_frontend/features/solicitudes_residente/domain/entities/solicitud_residente.dart';

void main() {
  test('parsea solicitud con personas e instalaciones', () {
    final dto = SolicitudResidenteDTO.fromJson({
      'id': 5,
      'proyecto_id': 1,
      'unidad_principal_id': 9,
      'unidad': 'Edificio-803',
      'agrupacion': 'Edificio',
      'tipo_solicitud': 'propietario',
      'origen': 'seeder',
      'estado': 'pendiente',
      'created_at': '2026-11-16 10:00:00',
      'personas': [
        {
          'id': 11,
          'usuario_id': 20,
          'nombre': 'Ana Demo',
          'rut': '12345678-5',
          'email': 'ana@example.test',
          'telefono': '+56911111111',
          'telefono_emergencia': '+56922222222',
          'nombre_emergencia': 'Contacto',
          'tipo_vinculo': 'propietario',
          'es_principal': true,
        },
      ],
      'instalaciones': [
        {
          'id': 3,
          'identificador': 'B-001',
          'tipo': 'bodega',
          'asignacion': 'departamento',
        },
      ],
    });

    final solicitud = dto.toEntity();

    expect(solicitud.estado, EstadoSolicitud.pendiente);
    expect(solicitud.tipoSolicitud, TipoSolicitud.propietario);
    expect(solicitud.personas.single.rut, '12345678-5');
    expect(solicitud.personaPrincipal?.nombre, 'Ana Demo');
    expect(solicitud.instalaciones.single.tipo, 'bodega');
  });

  test('parsea el tipo de solicitud residente', () {
    final solicitud = SolicitudResidenteDTO.fromJson({
      'id': 7,
      'proyecto_id': 1,
      'unidad_principal_id': 9,
      'unidad': 'Edificio-805',
      'agrupacion': 'Edificio',
      'tipo_solicitud': 'residente',
      'estado': 'pendiente',
    }).toEntity();

    expect(solicitud.tipoSolicitud, TipoSolicitud.residente);
  });

  test('tolera valores ausentes y estados desconocidos', () {
    final solicitud = SolicitudResidenteDTO.fromJson({
      'id': 6,
      'proyecto_id': 1,
      'unidad_principal_id': 9,
      'unidad': 'Edificio-804',
      'agrupacion': 'Edificio',
      'tipo_solicitud': 'arrendatario',
      'estado': 'desconocido',
    }).toEntity();

    expect(solicitud.estado, EstadoSolicitud.pendiente);
    expect(solicitud.tipoSolicitud, TipoSolicitud.arrendatario);
    expect(solicitud.personas, isEmpty);
    expect(solicitud.instalaciones, isEmpty);
  });
}
