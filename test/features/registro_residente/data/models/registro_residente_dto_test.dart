import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/features/registro_residente/data/models/registro_residente_dto.dart';
import 'package:torre_manager_frontend/features/registro_residente/domain/entities/registro_residente.dart';

void main() {
  test('parsea proyectos y unidades', () {
    final proyecto = ProyectoRegistroDTO.fromJson({
      'id': 3,
      'nombre': 'Condominio Demo',
    }).toEntity();

    final unidad = UnidadRegistroDTO.fromJson({
      'id': 9,
      'identificador': '101',
      'agrupacion': 'Torre A',
      'etiqueta': 'Torre A - 101',
    }).toEntity();

    expect(proyecto.id, '3');
    expect(proyecto.nombre, 'Condominio Demo');
    expect(unidad.etiqueta, 'Torre A - 101');
    expect(unidad.identificador, '101');
  });

  test('serializa la solicitud con principal y convivientes', () {
    final dto = SolicitudRegistroDTO.fromEntity(
      const SolicitudRegistro(
        proyectoId: '3',
        unidadPrincipalId: '9',
        tipoVinculo: TipoVinculoRegistro.arrendatario,
        password: 'password123',
        personas: [
          PersonaRegistro(
            nombre: 'Principal Demo',
            rut: '12345678-5',
            email: 'principal@example.test',
            telefono: '+56911111111',
            telefonoEmergencia: '+56922222222',
            nombreEmergencia: 'Contacto',
          ),
          PersonaRegistro(
            nombre: 'Conviviente Demo',
            rut: '15000002-5',
            email: 'conviviente@example.test',
            telefono: '+56933333333',
            telefonoEmergencia: '+56944444444',
            nombreEmergencia: 'Contacto Dos',
          ),
        ],
        mascotas: [
          MascotaRegistro(
            nombre: 'Firulais',
            especie: EspecieMascota.canino,
            raza: 'Mestizo',
            microchip: '123456789012345',
          ),
        ],
      ),
    );

    final json = dto.toJson();

    expect(json['proyecto_id'], '3');
    expect(json['unidad_principal_id'], '9');
    expect(json['password_confirmation'], 'password123');

    final personas = json['personas'] as List<dynamic>;
    expect(personas, hasLength(2));
    expect((personas.first as Map)['tipo_vinculo'], 'arrendatario');
    expect((personas.first as Map)['es_principal'], true);
    expect((personas.last as Map)['tipo_vinculo'], 'residente');
    expect((personas.last as Map)['es_principal'], false);

    final mascotas = json['mascotas'] as List<dynamic>;
    expect((mascotas.first as Map)['especie'], 'canino');
    expect((mascotas.first as Map)['microchip'], '123456789012345');
  });

  test('mapea las especies al valor de API', () {
    expect(EspecieMascota.pequenoMamifero.apiValue, 'pequeno_mamifero');
    expect(EspecieMascota.aveDomestica.apiValue, 'ave_domestica');
  });
}
