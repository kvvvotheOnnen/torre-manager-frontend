import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/features/infraestructura/data/models/unidad_accesoria_dto.dart';
import 'package:torre_manager_frontend/features/infraestructura/domain/entities/tipo_asignacion.dart';

void main() {
  Map<String, dynamic> json({String? asignacion}) {
    return {
      'id': '1',
      'proyecto_id': '7',
      'identificador': 'E-001',
      'tipo': 'estacionamiento',
      'asignacion': asignacion,
      'unidad_principal_id': null,
    };
  }

  test('interpreta la asignación nula como sin asignar', () {
    final accesoria = UnidadAccesoriaDTO.fromJson(json()).toEntity();

    expect(accesoria.asignacion, isNull);
  });

  test('preserva otro cuando viene seleccionado explícitamente', () {
    final accesoria = UnidadAccesoriaDTO.fromJson(json(asignacion: 'otro'))
        .toEntity();

    expect(accesoria.asignacion, TipoAsignacion.otro);
  });
}
