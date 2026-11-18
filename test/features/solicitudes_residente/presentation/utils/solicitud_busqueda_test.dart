import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/features/solicitudes_residente/domain/entities/solicitud_residente.dart';
import 'package:torre_manager_frontend/features/solicitudes_residente/presentation/utils/solicitud_busqueda.dart';

const _solicitud = SolicitudResidente(
  id: '1',
  proyectoId: '1',
  unidadPrincipalId: '9',
  unidad: 'Edificio-803',
  agrupacion: 'Torre Norte',
  tipoSolicitud: TipoSolicitud.propietario,
  origen: OrigenSolicitud.seeder,
  estado: EstadoSolicitud.pendiente,
  motivoRechazo: 'Documentación incompleta',
  createdAt: '2026-11-16 10:00:00',
  personas: [
    PersonaSolicitud(
      id: '10',
      nombre: 'María José Pérez',
      rut: '12345678-5',
      email: 'maria.perez@example.test',
      telefono: '+56912345678',
      telefonoEmergencia: '+56987654321',
      nombreEmergencia: 'Carlos Pérez',
      tipoVinculo: 'propietario',
      esPrincipal: true,
    ),
  ],
  instalaciones: [
    InstalacionUnidad(id: '3', identificador: 'B-001', tipo: 'bodega'),
  ],
);

void main() {
  test('encuentra por nombre, rut, correo, teléfono y unidad', () {
    expect(solicitudCoincide(_solicitud, 'maria'), isTrue);
    expect(solicitudCoincide(_solicitud, '12345678'), isTrue);
    expect(solicitudCoincide(_solicitud, 'perez@example'), isTrue);
    expect(solicitudCoincide(_solicitud, '912345678'), isTrue);
    expect(solicitudCoincide(_solicitud, 'edificio 803'), isTrue);
  });

  test('ignora acentos y mayúsculas', () {
    expect(solicitudCoincide(_solicitud, 'MARIA JOSE'), isTrue);
    expect(solicitudCoincide(_solicitud, 'documentacion'), isTrue);
  });

  test('busca en instalaciones y en varios términos', () {
    expect(solicitudCoincide(_solicitud, 'bodega b-001'), isTrue);
    expect(solicitudCoincide(_solicitud, 'maria torre'), isTrue);
    expect(solicitudCoincide(_solicitud, 'maria quincho'), isFalse);
  });

  test('una búsqueda vacía muestra todo', () {
    expect(solicitudCoincide(_solicitud, ''), isTrue);
    expect(solicitudCoincide(_solicitud, '   '), isTrue);
  });
}
