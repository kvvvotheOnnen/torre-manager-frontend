import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/utils/formato_moneda.dart';
import '../../../../core/utils/formato_texto.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/mi_informacion.dart';

class UnidadVinculadaCard extends StatelessWidget {
  const UnidadVinculadaCard({super.key, required this.unidad});

  final UnidadVinculada unidad;

  String get _vinculoLegible {
    final texto = unidad.tipoVinculo.orPlaceholder('Sin vínculo');
    return texto[0].toUpperCase() + texto.substring(1);
  }

  String? get _desde {
    final fecha = DateTime.tryParse(unidad.fechaInicio ?? '');
    final texto = formatearFecha(fecha);
    return texto.isEmpty ? null : texto;
  }

  String? get _hasta {
    final fecha = DateTime.tryParse(unidad.fechaFin ?? '');
    final texto = formatearFecha(fecha);
    return texto.isEmpty ? null : texto;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final theme = Theme.of(context);

    final estadoTexto = unidad.esActual ? 'Actual' : 'Histórico';
    final estadoColor = unidad.esActual ? p.success : p.inkMuted;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: p.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadii.smAll,
                ),
                child: Icon(
                  Icons.apartment_rounded,
                  color: p.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unidad.unidad.orPlaceholder('Unidad sin identificar'),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      unidad.agrupacion.orPlaceholder('Sin agrupación'),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: estadoColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  estadoTexto,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: estadoColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _MetaChip(icono: Icons.link_rounded, texto: _vinculoLegible),
              if (_desde != null)
                _MetaChip(
                  icono: Icons.event_available_rounded,
                  texto: 'Desde $_desde',
                ),
              if (_hasta != null)
                _MetaChip(
                  icono: Icons.event_busy_rounded,
                  texto: 'Hasta $_hasta',
                )
              else if (unidad.esActual)
                const _MetaChip(
                  icono: Icons.verified_rounded,
                  texto: 'Vigente',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: p.inkMuted),
          const SizedBox(width: 4),
          Text(
            texto,
            style: theme.textTheme.bodySmall?.copyWith(color: p.inkMuted),
          ),
        ],
      ),
    );
  }
}
