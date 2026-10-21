import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/superadmin_bloc.dart';

class ProyectosScreen extends StatelessWidget {
  const ProyectosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Proyectos')),
      body: BlocConsumer<SuperadminBloc, SuperadminState>(
        listener: (context, state) {
          if (state.mensaje != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.mensaje!),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
          }
        },
        builder: (context, state) {
          if (state.proyectos.isEmpty &&
              !state.cargando &&
              state.mensaje == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<SuperadminBloc>().add(const ProyectosSolicitados());
            });
          }

          if (state.cargando && state.proyectos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.proyectos.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<SuperadminBloc>().add(
                  const ProyectosSolicitados(),
                );
              },
              child: ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('No hay proyectos registrados.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<SuperadminBloc>().add(const ProyectosSolicitados());
            },
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (state.cargando) const LinearProgressIndicator(),
                ...state.proyectos.map(
                  (proyecto) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.domain, size: 36),
                      title: Text(
                        proyecto.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        proyecto.descripcion ?? 'Proyecto (tenant)',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${proyecto.agrupaciones} agrup.'),
                          Text('${proyecto.unidadesPrincipales} unidades'),
                          Text('${proyecto.unidadesAccesorias} accesorias'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
