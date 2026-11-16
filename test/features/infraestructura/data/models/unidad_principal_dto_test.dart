import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/features/infraestructura/data/models/unidad_principal_dto.dart';

void main() {
  test('parsea propietario y ocupante del árbol', () {
    final dto = UnidadPrincipalDTO.fromJson({
      'id': 10,
      'agrupacion_id': 2,
      'identificador': 'Edificio-801',
      'propietario_id': 5,
      'propietario_nombre': 'Ana',
      'ocupante_id': 7,
      'ocupante_nombre': 'Luis',
      'ocupante_tipo': 'arrendatario',
    });

    final entity = dto.toEntity();

    expect(entity.identificador, 'Edificio-801');
    expect(entity.propietarioId, '5');
    expect(entity.propietarioNombre, 'Ana');
    expect(entity.ocupanteId, '7');
    expect(entity.ocupanteTipo, 'arrendatario');
  });
}
