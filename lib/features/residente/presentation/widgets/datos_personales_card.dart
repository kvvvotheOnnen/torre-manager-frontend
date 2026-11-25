import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/utils/formato_telefono.dart';
import '../../../../core/utils/formato_texto.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/domain/entities/usuario.dart';

class DatosPersonalesCard extends StatelessWidget {
  const DatosPersonalesCard({super.key, required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final theme = Theme.of(context);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline_rounded, color: p.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text('Datos personales', style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              const separacion = AppSpacing.md;
              final dosColumnas = constraints.maxWidth >= 520;
              final ancho = dosColumnas
                  ? (constraints.maxWidth - separacion) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: separacion,
                runSpacing: separacion,
                children: [
                  SizedBox(
                    width: ancho,
                    child: _DatoTile(
                      icono: Icons.badge_outlined,
                      etiqueta: 'RUT',
                      valor: usuario.rut.orPlaceholder('No registrado'),
                    ),
                  ),
                  SizedBox(
                    width: ancho,
                    child: _DatoTile(
                      icono: Icons.mail_outline_rounded,
                      etiqueta: 'Correo',
                      valor: usuario.correo.orPlaceholder('No registrado'),
                    ),
                  ),
                  SizedBox(
                    width: ancho,
                    child: _DatoTile(
                      icono: Icons.phone_outlined,
                      etiqueta: 'Teléfono',
                      valor: formatearTelefono(
                        usuario.telefono,
                        marcador: 'No registrado',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: ancho,
                    child: _DatoTile(
                      icono: Icons.emergency_outlined,
                      etiqueta: 'Contacto de emergencia',
                      valor: _contactoEmergencia(),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
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

class _DatoTile extends StatelessWidget {
  const _DatoTile({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: p.primary.withValues(alpha: 0.1),
            borderRadius: AppRadii.smAll,
          ),
          child: Icon(icono, size: 18, color: p.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiqueta,
                style: theme.textTheme.bodySmall?.copyWith(color: p.inkMuted),
              ),
              const SizedBox(height: 1),
              Text(valor, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
