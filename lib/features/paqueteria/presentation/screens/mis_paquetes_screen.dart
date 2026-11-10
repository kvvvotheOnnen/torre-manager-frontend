import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/paqueteria_bloc.dart';
import '../widgets/paquete_card_image.dart';
import '../widgets/paquete_detalle_dialog.dart';
import '../../domain/entities/paquete.dart';

class MisPaquetesScreen extends StatefulWidget {
  const MisPaquetesScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<MisPaquetesScreen> createState() => _MisPaquetesScreenState();
}

class _MisPaquetesScreenState extends State<MisPaquetesScreen> {
  final _busquedaController = TextEditingController();
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PaqueteriaBloc>().add(const PaqueteriaSolicitada());
    });
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  List<Paquete> _filtrar(List<Paquete> paquetes, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return paquetes;
    return paquetes.where((p) {
      return p.descripcion.toLowerCase().contains(q) ||
          (p.remitente?.toLowerCase().contains(q) ?? false) ||
          p.fechaRecepcion.toLowerCase().contains(q) ||
          p.estado.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis paquetes'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(const LogoutRequested()),
          ),
        ],
      ),
      body: BlocBuilder<PaqueteriaBloc, PaqueteriaState>(
        builder: (context, state) {
          if (state.status == PaqueteriaStatus.cargando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == PaqueteriaStatus.error &&
              state.paquetes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.mensaje ?? 'No fue posible cargar los paquetes.'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => context.read<PaqueteriaBloc>().add(
                      const PaqueteriaSolicitada(),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final paquetesFiltrados = _filtrar(state.paquetes, _busqueda);

          if (state.paquetes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 56,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 12),
                  const Text('No tienes paquetes registrados.'),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _busquedaController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por descripción, remitente o fecha',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _busqueda.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _busquedaController.clear();
                              setState(() => _busqueda = '');
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _busqueda = v),
                ),
              ),
              Expanded(
                child: paquetesFiltrados.isEmpty
                    ? Center(
                        child: Text(
                          'Sin resultados para "$_busqueda".',
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 320,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  mainAxisExtent: 340,
                                ),
                            itemCount: paquetesFiltrados.length,
                            itemBuilder: (context, index) => _TarjetaPaquete(
                              paquete: paquetesFiltrados[index],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TarjetaPaquete extends StatelessWidget {
  const _TarjetaPaquete({required this.paquete});

  final Paquete paquete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pendiente = paquete.estaPendiente;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showDialog<void>(
          context: context,
          builder: (_) => PaqueteDetalleDialog(paquete: paquete),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: PaqueteCardImage(fotoUrl: paquete.fotoUrl)),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paquete.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (paquete.remitente != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'De: ${paquete.remitente}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    'Recibido: ${paquete.fechaRecepcion}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (paquete.retiradoPorNombre != null &&
                      paquete.retiradoPorNombre!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Retirado por: ${paquete.retiradoPorNombre}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Chip(
                    label: Text(pendiente ? 'Pendiente' : 'Retirado'),
                    backgroundColor: pendiente
                        ? theme.colorScheme.errorContainer
                        : theme.colorScheme.tertiaryContainer,
                    labelStyle: TextStyle(
                      color: pendiente
                          ? theme.colorScheme.onErrorContainer
                          : theme.colorScheme.onTertiaryContainer,
                      fontSize: 12,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
