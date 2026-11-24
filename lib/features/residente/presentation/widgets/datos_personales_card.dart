import 'package:flutter/material.dart';

import '../../../../core/utils/formato_telefono.dart';
import '../../../../core/utils/formato_texto.dart';
import '../../../auth/domain/entities/usuario.dart';

class DatosPersonalesCard extends StatelessWidget {
  const DatosPersonalesCard({super.key, required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Datos personales',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _FilaDato(
              icono: Icons.badge_outlined,
              etiqueta: 'RUT',
              valor: usuario.rut.orPlaceholder('No registrado'),
            ),
            const Divider(),
            _FilaDato(
              icono: Icons.phone_outlined,
              etiqueta: 'Teléfono',
              valor: formatearTelefono(
                usuario.telefono,
                marcador: 'No registrado',
              ),
            ),
            const Divider(),
            _FilaDato(
              icono: Icons.emergency_outlined,
              etiqueta: 'Contacto de emergencia',
              valor: _contactoEmergencia(),
            ),
          ],
        ),
      ),
    );
  }

  String _contactoEmergencia() {
    final nombre = usuario.nombreEmergencia.orPlaceholder('').trim();
    final telefono = formatearTelefono(
      usuario.telefonoEmergencia,
      marcador: '',
    ).trim();

    if (nombre.isEmpty && telefono.isEmpty) return 'No registrado';
    if (nombre.isEmpty) return telefono;
    if (telefono.isEmpty) return nombre;

    return '$nombre · $telefono';
  }
}

class _FilaDato extends StatelessWidget {
  const _FilaDato({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiqueta,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(valor, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
