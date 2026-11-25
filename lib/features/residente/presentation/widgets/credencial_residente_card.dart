import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/utils/formato_telefono.dart';
import '../../../../core/utils/formato_texto.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../domain/entities/mi_informacion.dart';

/// Credencial del residente con diseño de carnet: foto genérica, identidad
/// y datos de contacto y unidad.
class CredencialResidenteCard extends StatelessWidget {
  const CredencialResidenteCard({
    super.key,
    required this.usuario,
    this.unidad,
  });

  final Usuario usuario;
  final UnidadVinculada? unidad;

  String get _rol {
    final texto = usuario.rol.name;
    return texto[0].toUpperCase() + texto.substring(1);
  }

  String get _estado {
    if (unidad == null) return 'SIN UNIDAD';
    return unidad!.esActual ? 'ACTIVA' : 'HISTÓRICA';
  }

  String get _contactoEmergencia {
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

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final theme = Theme.of(context);
    final activa = unidad?.esActual ?? false;
    final estadoColor = unidad == null
        ? Colors.white70
        : (activa ? p.success : Colors.white70);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: GlassCard(
          gradient: p.hero,
          glowColor: p.primary,
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: AppRadii.xlAll,
            child: Stack(
              children: [
                Positioned(
                  right: -18,
                  bottom: -24,
                  child: Icon(
                    Icons.apartment_rounded,
                    size: 190,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 3,
                      decoration: BoxDecoration(gradient: p.gold),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.lg,
                        AppSpacing.xl,
                        AppSpacing.xl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Encabezado(),
                          const SizedBox(height: AppSpacing.xl),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FotoGenerica(),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      usuario.nombre.orPlaceholder('Residente'),
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(color: Colors.white),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Wrap(
                                      spacing: AppSpacing.xs,
                                      runSpacing: AppSpacing.xs,
                                      children: [
                                        _Etiqueta(
                                          texto: _rol,
                                          color: Colors.white,
                                          fondo: Colors.white.withValues(
                                            alpha: 0.14,
                                          ),
                                        ),
                                        _Etiqueta(
                                          texto: _estado,
                                          color: estadoColor,
                                          fondo: estadoColor.withValues(
                                            alpha: 0.16,
                                          ),
                                          letterSpacing: 1.1,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.mail_outline_rounded,
                                          size: 14,
                                          color: Colors.white70,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            usuario.correo.orPlaceholder(
                                              'Sin correo',
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: Colors.white70,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Divider(
                            color: Colors.white.withValues(alpha: 0.14),
                            height: 1,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              const separacion = AppSpacing.lg;
                              final dosColumnas = constraints.maxWidth >= 460;
                              final ancho = dosColumnas
                                  ? (constraints.maxWidth - separacion) / 2
                                  : constraints.maxWidth;

                              return Wrap(
                                spacing: separacion,
                                runSpacing: AppSpacing.md,
                                children: [
                                  SizedBox(
                                    width: ancho,
                                    child: _Dato(
                                      icono: Icons.badge_outlined,
                                      etiqueta: 'RUT',
                                      valor: usuario.rut.orPlaceholder(
                                        'No registrado',
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: ancho,
                                    child: _Dato(
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
                                    child: _Dato(
                                      icono: Icons.door_front_door_outlined,
                                      etiqueta: 'Unidad',
                                      valor:
                                          unidad?.unidad.orPlaceholder(
                                            'Sin unidad',
                                          ) ??
                                          'Sin unidad',
                                    ),
                                  ),
                                  SizedBox(
                                    width: ancho,
                                    child: _Dato(
                                      icono: Icons.emergency_outlined,
                                      etiqueta: 'Contacto de emergencia',
                                      valor: _contactoEmergencia,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: const Icon(
            Icons.apartment_rounded,
            size: 19,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'TORRE MANAGER',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              letterSpacing: 1.8,
            ),
          ),
        ),
        Text(
          'CREDENCIAL DE RESIDENTE',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white70,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _FotoGenerica extends StatelessWidget {
  const _FotoGenerica();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 112,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: const Icon(Icons.person_rounded, size: 54, color: Colors.white),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({
    required this.texto,
    required this.color,
    required this.fondo,
    this.letterSpacing = 0.2,
  });

  final String texto;
  final Color color;
  final Color fondo;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: color, letterSpacing: letterSpacing),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({
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
        Icon(icono, size: 18, color: Colors.white70),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiqueta,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                valor,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
