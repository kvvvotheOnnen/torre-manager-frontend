import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/features/superadmin/data/models/administrador_dto.dart';

void main() {
  test('parsea administrador con proyectos', () {
    final dto = AdministradorDTO.fromJson({
      'id': 7,
      'nombre': 'Admin Demo',
      'email': 'admin@example.test',
      'rol': 'administrador',
      'proyectos': [
        {'id': 1, 'nombre': 'Proyecto A'},
        {'id': 2, 'nombre': 'Proyecto B'},
      ],
    });

    final entity = dto.toEntity();

    expect(entity.id, '7');
    expect(entity.nombre, 'Admin Demo');
    expect(entity.correo, 'admin@example.test');
    expect(
      entity.proyectos.map((proyecto) => proyecto.nombre),
      ['Proyecto A', 'Proyecto B'],
    );
    expect(entity.proyectos.first.id, '1');
  });

  test('tolera proyectos ausentes o inválidos', () {
    final entity = AdministradorDTO.fromJson({
      'id': 9,
      'nombre': 'Sin Proyectos',
      'email': 'sin@example.test',
      'proyectos': null,
    }).toEntity();

    expect(entity.proyectos, isEmpty);
  });
}
