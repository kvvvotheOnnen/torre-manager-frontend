import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/solicitud_residente.dart';
import '../bloc/solicitudes_residente_bloc.dart';
import '../utils/solicitud_busqueda.dart';

class GestionResidentesScreen extends StatefulWidget {
  const GestionResidentesScreen({super.key});

  @override
  State<GestionResidentesScreen> createState() =>
      _GestionResidentesScreenState();
}

class _GestionResidentesScreenState extends State<GestionResidentesScreen> {
  final _busquedaController = TextEditingController();
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SolicitudesResidenteBloc>().add(
        const SolicitudesResidenteIniciadas(),
      );
    });
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  void _limpiarBusqueda() {
    _busquedaController.clear();
    setState(() => _busqueda = '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de residentes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
      ),
      body: BlocConsumer<SolicitudesResidenteBloc, SolicitudesResidenteState>(
        listener: (context, state) {
          final mensaje = state.mensaje;
          if (mensaje == null) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(mensaje)));
          context.read<SolicitudesResidenteBloc>().add(
            const MensajeSolicitudesLimpiado(),
          );
        },
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  controller: _busquedaController,
                  onChanged: (value) => setState(() => _busqueda = value),
                  decoration: InputDecoration(
                    hintText:
                        'Buscar por nombre, RUT, correo, teléfono, unidad...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _busqueda.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpiar búsqueda',
                            icon: const Icon(Icons.clear),
                            onPressed: _limpiarBusqueda,
                          ),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final esDesktop = constraints.maxWidth >= 900;

                    if (!esDesktop) {
                      return Column(
                        children: [
                          _SelectorVista(state: state),
                          Expanded(
                            child: _Contenido(
                              state: state,
                              busqueda: _busqueda,
                              onLimpiarBusqueda: _limpiarBusqueda,
                            ),
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        SizedBox(width: 260, child: _Sidebar(state: state)),
                        const VerticalDivider(width: 1),
                        Expanded(
                          child: _Contenido(
                            state: state,
                            busqueda: _busqueda,
                            onLimpiarBusqueda: _limpiarBusqueda,
                          ),
                        ),
                      ],
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

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.state});

  final SolicitudesResidenteState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _OpcionVista(
          icono: Icons.pending_actions_outlined,
          titulo: 'Pendientes',
          cantidad: state.pendientes.length,
          seleccionada: state.vista == VistaSolicitudes.pendientes,
          onTap: () => _cambiarVista(context, VistaSolicitudes.pendientes),
        ),
        _OpcionVista(
          icono: Icons.history,
          titulo: 'Historial',
          cantidad: state.historial.length,
          seleccionada: state.vista == VistaSolicitudes.historial,
          onTap: () => _cambiarVista(context, VistaSolicitudes.historial),
        ),
      ],
    );
  }

  void _cambiarVista(BuildContext context, VistaSolicitudes vista) {
    context.read<SolicitudesResidenteBloc>().add(
      VistaSolicitudesCambiada(vista),
    );
  }
}

class _OpcionVista extends StatelessWidget {
  const _OpcionVista({
    required this.icono,
    required this.titulo,
    required this.cantidad,
    required this.seleccionada,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final int cantidad;
  final bool seleccionada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: seleccionada ? theme.colorScheme.secondaryContainer : null,
      child: ListTile(
        leading: Icon(icono),
        title: Text(titulo),
        trailing: Badge(label: Text('$cantidad')),
        onTap: onTap,
      ),
    );
  }
}

class _SelectorVista extends StatelessWidget {
  const _SelectorVista({required this.state});

  final SolicitudesResidenteState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SegmentedButton<VistaSolicitudes>(
        segments: [
          ButtonSegment(
            value: VistaSolicitudes.pendientes,
            label: Text('Pendientes (${state.pendientes.length})'),
            icon: const Icon(Icons.pending_actions_outlined),
          ),
          ButtonSegment(
            value: VistaSolicitudes.historial,
            label: Text('Historial (${state.historial.length})'),
            icon: const Icon(Icons.history),
          ),
        ],
        selected: {state.vista},
        onSelectionChanged: (seleccion) {
          context.read<SolicitudesResidenteBloc>().add(
            VistaSolicitudesCambiada(seleccion.first),
          );
        },
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({
    required this.state,
    required this.busqueda,
    required this.onLimpiarBusqueda,
  });

  final SolicitudesResidenteState state;
  final String busqueda;
  final VoidCallback onLimpiarBusqueda;

  @override
  Widget build(BuildContext context) {
    final esPendientes = state.vista == VistaSolicitudes.pendientes;
    final todas = esPendientes ? state.pendientes : state.historial;
    final solicitudes = todas
        .where((solicitud) => solicitudCoincide(solicitud, busqueda))
        .toList();
    final cargando = state.status == SolicitudesResidenteStatus.cargando;

    if (cargando && todas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == SolicitudesResidenteStatus.error && todas.isEmpty) {
      return _EstadoVacio(
        icono: Icons.error_outline,
        mensaje: state.mensaje ?? 'No fue posible cargar las solicitudes.',
        accion: FilledButton.icon(
          onPressed: () {
            final bloc = context.read<SolicitudesResidenteBloc>();
            bloc.add(
              esPendientes
                  ? const SolicitudesPendientesSolicitadas()
                  : const HistorialSolicitudesSolicitado(),
            );
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
      );
    }

    if (todas.isEmpty) {
      return _EstadoVacio(
        icono: esPendientes ? Icons.inbox_outlined : Icons.history,
        mensaje: esPendientes
            ? 'No hay solicitudes pendientes.'
            : 'Aún no hay solicitudes decididas.',
      );
    }

    if (solicitudes.isEmpty) {
      return _EstadoVacio(
        icono: Icons.search_off,
        mensaje: 'No hay solicitudes que coincidan con la búsqueda.',
        accion: TextButton.icon(
          onPressed: onLimpiarBusqueda,
          icon: const Icon(Icons.clear),
          label: const Text('Limpiar búsqueda'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final bloc = context.read<SolicitudesResidenteBloc>();
        bloc.add(
          esPendientes
              ? const SolicitudesPendientesSolicitadas()
              : const HistorialSolicitudesSolicitado(),
        );
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: solicitudes.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final solicitud = solicitudes[index];
          return _TarjetaSolicitud(
            solicitud: solicitud,
            esPendiente: esPendientes,
          );
        },
      ),
    );
  }
}

class _TarjetaSolicitud extends StatelessWidget {
  const _TarjetaSolicitud({required this.solicitud, required this.esPendiente});

  final SolicitudResidente solicitud;
  final bool esPendiente;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final principal = solicitud.personaPrincipal;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _abrirDetalle(context, solicitud),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      esPendiente ? Icons.person_add_alt_1 : Icons.history,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          principal?.nombre ?? 'Sin persona principal',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'RUT ${principal?.rut ?? '—'} · ${solicitud.unidad}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _EstadoChip(estado: solicitud.estado),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(solicitud.tipoSolicitud.name)),
                  Chip(label: Text('${solicitud.personas.length} persona(s)')),
                  Chip(label: Text(solicitud.agrupacion)),
                ],
              ),
              if (solicitud.motivoRechazo != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Motivo: ${solicitud.motivoRechazo}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  const _EstadoChip({required this.estado});

  final EstadoSolicitud estado;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (color, icono) = switch (estado) {
      EstadoSolicitud.pendiente => (Colors.orange, Icons.schedule),
      EstadoSolicitud.aprobada => (Colors.green, Icons.check_circle),
      EstadoSolicitud.rechazada => (theme.colorScheme.error, Icons.cancel),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            estado.name,
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio({required this.icono, required this.mensaje, this.accion});

  final IconData icono;
  final String mensaje;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 56, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(mensaje, textAlign: TextAlign.center),
            if (accion != null) ...[const SizedBox(height: 16), accion!],
          ],
        ),
      ),
    );
  }
}

Future<void> _abrirDetalle(
  BuildContext context,
  SolicitudResidente solicitud,
) async {
  final aprobada = await showDialog<bool>(
    context: context,
    builder: (context) => _DetalleSolicitudDialog(solicitud: solicitud),
  );

  if (aprobada == true && context.mounted) {
    context.read<SolicitudesResidenteBloc>().add(
      SolicitudAprobada(solicitud.id),
    );
  }
}

class _DetalleSolicitudDialog extends StatefulWidget {
  const _DetalleSolicitudDialog({required this.solicitud});

  final SolicitudResidente solicitud;

  @override
  State<_DetalleSolicitudDialog> createState() =>
      _DetalleSolicitudDialogState();
}

class _DetalleSolicitudDialogState extends State<_DetalleSolicitudDialog> {
  final _motivoController = TextEditingController();
  bool _mostrarRechazo = false;

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final solicitud = widget.solicitud;
    final pendiente = solicitud.estado == EstadoSolicitud.pendiente;

    return AlertDialog(
      title: Text(
        'Solicitud de ${solicitud.personaPrincipal?.nombre ?? 'residente'}',
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _FilaDato(etiqueta: 'Unidad', valor: solicitud.unidad),
              _FilaDato(etiqueta: 'Agrupación', valor: solicitud.agrupacion),
              _FilaDato(etiqueta: 'Tipo', valor: solicitud.tipoSolicitud.name),
              _FilaDato(etiqueta: 'Estado', valor: solicitud.estado.name),
              if (solicitud.solicitadoPorNombre != null)
                _FilaDato(
                  etiqueta: 'Solicitado por',
                  valor: solicitud.solicitadoPorNombre!,
                ),
              if (solicitud.decididoPorNombre != null)
                _FilaDato(
                  etiqueta: 'Decidido por',
                  valor: solicitud.decididoPorNombre!,
                ),
              if (solicitud.motivoRechazo != null)
                _FilaDato(etiqueta: 'Motivo', valor: solicitud.motivoRechazo!),
              const Divider(height: 24),
              Text('Personas', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              ...solicitud.personas.map(
                (persona) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                persona.nombre,
                                style: theme.textTheme.titleSmall,
                              ),
                            ),
                            if (persona.esPrincipal)
                              const Chip(label: Text('Principal')),
                          ],
                        ),
                        _FilaDato(etiqueta: 'RUT', valor: persona.rut),
                        _FilaDato(etiqueta: 'Correo', valor: persona.email),
                        _FilaDato(
                          etiqueta: 'Teléfono',
                          valor: persona.telefono,
                        ),
                        _FilaDato(
                          etiqueta: 'Emergencia',
                          valor:
                              '${persona.nombreEmergencia} · ${persona.telefonoEmergencia}',
                        ),
                        _FilaDato(
                          etiqueta: 'Vínculo',
                          valor: persona.tipoVinculo,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 24),
              Text(
                'Instalaciones de la unidad',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              if (solicitud.instalaciones.isEmpty)
                const Text('La unidad no tiene bodegas ni estacionamientos.')
              else
                ...solicitud.instalaciones.map(
                  (instalacion) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      instalacion.tipo == 'bodega'
                          ? Icons.warehouse_outlined
                          : Icons.local_parking_outlined,
                    ),
                    title: Text(instalacion.identificador),
                    subtitle: Text(
                      '${instalacion.tipo}${instalacion.asignacion != null ? ' · ${instalacion.asignacion}' : ''}',
                    ),
                  ),
                ),
              if (_mostrarRechazo) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _motivoController,
                  maxLength: 500,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Razones / observaciones',
                    hintText: 'Escribe la razón del rechazo',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (!pendiente)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        if (pendiente && !_mostrarRechazo) ...[
          TextButton(
            onPressed: () => setState(() => _mostrarRechazo = true),
            child: const Text('Rechazar'),
          ),
          FilledButton(
            onPressed: () => _confirmarAceptacion(context),
            child: const Text('Aceptar'),
          ),
        ],
        if (pendiente && _mostrarRechazo) ...[
          TextButton(
            onPressed: () => setState(() => _mostrarRechazo = false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => _rechazar(context),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Rechazar'),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmarAceptacion(BuildContext context) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar aprobación'),
        content: const Text('¿Verificaste la información correctamente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sí'),
          ),
        ],
      ),
    );

    if (confirmado == true && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _rechazar(BuildContext context) {
    final motivo = _motivoController.text.trim();

    if (motivo.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe la razón del rechazo.')),
      );
      return;
    }

    context.read<SolicitudesResidenteBloc>().add(
      SolicitudRechazada(widget.solicitud.id, motivo),
    );
    Navigator.of(context).pop(false);
  }
}

class _FilaDato extends StatelessWidget {
  const _FilaDato({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              etiqueta,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(valor, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
