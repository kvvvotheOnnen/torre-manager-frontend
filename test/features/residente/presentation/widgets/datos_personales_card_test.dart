import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torre_manager_frontend/features/auth/domain/entities/usuario.dart';
import 'package:torre_manager_frontend/features/residente/presentation/widgets/datos_personales_card.dart';

const _usuario = Usuario(
  id: '1',
  nombre: 'Usuario Demo',
  correo: 'demo@example.test',
  rol: Rol.residente,
  rut: '12345678-5',
  telefono: '+56911111111',
  telefonoEmergencia: '+56922222222',
  nombreEmergencia: 'Contacto Demo',
);

void main() {
  testWidgets('muestra RUT, teléfono y contacto de emergencia', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: DatosPersonalesCard(usuario: _usuario)),
      ),
    );

    expect(find.text('Datos personales'), findsOneWidget);
    expect(find.text('12345678-5'), findsOneWidget);
    expect(find.text('+56 9 1111 1111'), findsOneWidget);
    expect(find.text('Contacto Demo · +56 9 2222 2222'), findsOneWidget);
  });

  testWidgets('muestra "No registrado" cuando no hay datos', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DatosPersonalesCard(
            usuario: Usuario(
              id: '2',
              nombre: 'Sin Datos',
              correo: 'sin-datos@example.test',
              rol: Rol.conserje,
            ),
          ),
        ),
      ),
    );

    expect(find.text('No registrado'), findsNWidgets(3));
  });
}
