import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/modulo_dashboard.dart';
import '../bloc/modulos_dashboard_bloc.dart';

/// Argumentos opcionales para personalizar la pantalla "Próximamente"
/// (usado, por ejemplo, por el dashboard preventivo del residente).
class ProximamenteArgs {
  const ProximamenteArgs({this.titulo, this.descripcion});

  final String? titulo;
  final String? descripcion;
}

class ModuloProximamenteScreen extends StatelessWidget {
  const ModuloProximamenteScreen({
    super.key,
    required this.moduloId,
    this.titulo,
    this.descripcion,
  });

  final String moduloId;
  final String? titulo;
  final String? descripcion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final modulo = _buscarModulo(context, moduloId);
    final nombre = titulo ?? modulo?.nombre ?? _tituloDesdeId(moduloId);
    final detalle =
        descripcion ??
        modulo?.descripcion ??
        'Este módulo estará disponible próximamente.';

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(title: Text(nombre)),
      body: AppBackground(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xxl + MediaQuery.viewPaddingOf(context).bottom,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppLayout.maxForm),
              child: GlassCard(
                glowColor: p.primary,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        gradient: p.brand,
                        borderRadius: AppRadii.lgAll,
                        boxShadow: AppShadows.glow(p.primary),
                      ),
                      child: const Icon(
                        Icons.construction_rounded,
                        size: 38,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    StatusPill(
                      label: 'PRÓXIMAMENTE',
                      color: p.accent,
                      icon: Icons.schedule_rounded,
                      compact: true,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      nombre,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      detalle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: p.inkMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    OutlinedButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Volver al panel'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

ModuloDashboard? _buscarModulo(BuildContext context, String id) {
  final state = context.watch<ModulosDashboardBloc>().state;
  for (final modulo in state.modulos) {
    if (modulo.id == id) return modulo;
  }
  return null;
}

String _tituloDesdeId(String id) {
  if (id.isEmpty) return 'Módulo';

  final texto = id.replaceAll('_', ' ');
  return texto[0].toUpperCase() + texto.substring(1);
}
