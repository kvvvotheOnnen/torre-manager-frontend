import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../bloc/tenant_bloc.dart';

class SelectorProyectoScreen extends StatelessWidget {
  const SelectorProyectoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Selecciona un proyecto')),
      body: BlocListener<TenantBloc, TenantState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == TenantStatus.listo,
        listener: (context, state) => context.go(AppRoutes.dashboard),
        child: BlocBuilder<TenantBloc, TenantState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Tienes acceso a más de un recinto. Elige con cuál trabajar.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ...state.proyectos.map(
                  (proyecto) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.domain, size: 36),
                      title: Text(
                        proyecto.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        proyecto.descripcion ??
                            '${proyecto.tipoCondominio.etiqueta} · '
                                '${proyecto.modulos.map((m) => m.etiqueta).join(', ')}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.read<TenantBloc>().add(
                        TenantProyectoSeleccionado(proyecto.id),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
