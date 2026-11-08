import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    final modulo = _buscarModulo(context, moduloId);
    final nombre = titulo ?? modulo?.nombre ?? _tituloDesdeId(moduloId);
    final detalle = descripcion ??
        modulo?.descripcion ??
        'Este módulo estará disponible próximamente.';

    return Scaffold(
      appBar: AppBar(title: Text(nombre)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.construction_outlined,
                  size: 72,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  nombre,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  detalle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Próximamente',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
