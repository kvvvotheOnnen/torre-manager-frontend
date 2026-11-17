import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/features/auth/data/models/usuario_dto.dart';
import 'package:torre_manager_frontend/features/auth/domain/entities/usuario.dart';

void main() {
  test('parsea datos personales del usuario', () {
    final dto = UsuarioDTO.fromJson({
      'id': 7,
      'nombre': 'Usuario Demo',
      'email': 'demo@example.test',
      'rol': 'residente',
      'rut': '12345678-5',
      'telefono': '+56911111111',
      'telefono_emergencia': '+56922222222',
      'nombre_emergencia': 'Contacto Demo',
    });

    final usuario = dto.toEntity();

    expect(usuario.rol, Rol.residente);
    expect(usuario.rut, '12345678-5');
    expect(usuario.telefono, '+56911111111');
    expect(usuario.telefonoEmergencia, '+56922222222');
    expect(usuario.nombreEmergencia, 'Contacto Demo');
  });

  test('mantiene datos personales nulos cuando no vienen en el JSON', () {
    final usuario = UsuarioDTO.fromJson({
      'id': 8,
      'nombre': 'Usuario Sin Datos',
      'email': 'sin-datos@example.test',
      'rol': 'conserje',
    }).toEntity();

    expect(usuario.rut, isNull);
    expect(usuario.telefono, isNull);
    expect(usuario.telefonoEmergencia, isNull);
    expect(usuario.nombreEmergencia, isNull);
  });
}
