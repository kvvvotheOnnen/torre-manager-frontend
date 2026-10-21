import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/arbol_infraestructura.dart';
import '../../domain/entities/tipo_agrupacion.dart';
import '../../domain/entities/tipo_unidad_accesoria.dart';
import '../../domain/entities/unidad_accesoria.dart';
import '../../domain/entities/unidad_principal.dart';
import '../bloc/infraestructura_bloc.dart';

class InfraestructuraScreen extends StatelessWidget {
  const InfraestructuraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Infraestructura')),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Registrar agrupación en cascada',
        onPressed: () => _mostrarDialogoAgrupacion(context),
        icon: const Icon(Icons.add_business),
        label: const Text('Agrupación'),
      ),
      body: const _InfraestructuraBody(),
    );
  }

  void _mostrarDialogoAgrupacion(BuildContext context) {
    final arbol = context.read<InfraestructuraBloc>().state.arbol;
    if (arbol == null) return;

    showDialog<void>(
      context: context,
      builder: (_) => _DialogoNuevaAgrupacion(proyectoId: arbol.proyecto.id),
    );
  }
}

class _InfraestructuraBody extends StatelessWidget {
  const _InfraestructuraBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InfraestructuraBloc, InfraestructuraState>(
      listener: (context, state) {
        if (state.mensaje != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.mensaje!),
                backgroundColor: state.status == InfraestructuraStatus.error
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
            );
          context
              .read<InfraestructuraBloc>()
              .add(const InfraestructuraMensajeConsumido());
        }
      },
      builder: (context, state) {
        if (state.status == InfraestructuraStatus.inicial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context
                .read<InfraestructuraBloc>()
                .add(const InfraestructuraIniciado());
          });
        }

        if (state.status == InfraestructuraStatus.cargando && state.arbol == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final arbol = state.arbol;

        if (arbol == null) {
          return const Center(child: Text('No hay datos de infraestructura.'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            context
                .read<InfraestructuraBloc>()
                .add(InfraestructuraArbolSolicitado(proyectoId: arbol.proyecto.id));
          },
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.apartment),
                  title: Text(
                    arbol.proyecto.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(arbol.proyecto.descripcion ?? 'Proyecto (tenant)'),
                ),
              ),
              if (state.tieneCarga)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: LinearProgressIndicator(),
                ),
              ...arbol.agrupaciones.map(
                (item) => _AgrupacionCard(item: item, proyectoId: arbol.proyecto.id),
              ),
              if (arbol.agrupaciones.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Aún no hay agrupaciones. Usa el botón "Agrupación" para '
                      'registrar una con sus unidades en cascada.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AgrupacionCard extends StatelessWidget {
  const _AgrupacionCard({required this.item, required this.proyectoId});

  final ArbolAgrupacion item;
  final String proyectoId;

  @override
  Widget build(BuildContext context) {
    final agrupacion = item.agrupacion;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        leading: const Icon(Icons.foundation),
        title: Text(agrupacion.nombre),
        subtitle: Text(
          '${agrupacion.tipo.name.toUpperCase()} · '
          '${item.unidadesPrincipales.length} unidades',
        ),
        children: [
          ...item.unidadesPrincipales.map(
            (unidad) => _UnidadPrincipalTile(
              unidad: unidad,
              proyectoId: proyectoId,
            ),
          ),
          if (item.unidadesPrincipales.isEmpty)
            const ListTile(
              dense: true,
              title: Text('Sin unidades registradas'),
            ),
        ],
      ),
    );
  }
}

class _UnidadPrincipalTile extends StatelessWidget {
  const _UnidadPrincipalTile({required this.unidad, required this.proyectoId});

  final ArbolUnidadPrincipal unidad;
  final String proyectoId;

  @override
  Widget build(BuildContext context) {
    final accesorias = unidad.unidadesAccesorias;

    return ExpansionTile(
      leading: const Icon(Icons.door_front_door, size: 20),
      title: Text('Unidad ${unidad.unidadPrincipal.identificador}'),
      subtitle: Text(
        accesorias.isEmpty
            ? 'Sin unidades accesorias asignadas'
            : accesorias
                .map((a) => '${_etiquetaTipo(a)} ${a.identificador}')
                .join(' · '),
      ),
      children: [
        ...accesorias.map(
          (accesoria) => ListTile(
            dense: true,
            leading: Icon(
              accesoria.tipo == TipoUnidadAccesoria.estacionamiento
                  ? Icons.directions_car
                  : Icons.inventory_2,
              size: 20,
            ),
            title: Text('${_etiquetaTipo(accesoria)} ${accesoria.identificador}'),
            subtitle: Text(
              accesoria.unidadPrincipalId == null
                  ? 'Libre disposición / comunitaria'
                  : 'Asignada a esta unidad',
            ),
            trailing: TextButton(
              onPressed: () => _mostrarDialogoAsignar(context, accesoria),
              child: const Text('Cambiar'),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _mostrarDialogoAccesoria(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Unidad accesoria'),
            ),
          ),
        ),
      ],
    );
  }

  String _etiquetaTipo(UnidadAccesoria accesoria) =>
      accesoria.tipo == TipoUnidadAccesoria.estacionamiento ? 'Estac.' : 'Bodega';

  void _mostrarDialogoAccesoria(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _DialogoNuevaAccesoria(
        proyectoId: proyectoId,
        unidadPrincipal: unidad.unidadPrincipal,
      ),
    );
  }

  void _mostrarDialogoAsignar(
    BuildContext context,
    UnidadAccesoria accesoria,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => _DialogoAsignarAccesoria(
        proyectoId: proyectoId,
        accesoria: accesoria,
      ),
    );
  }
}

class _DialogoNuevaAgrupacion extends StatefulWidget {
  const _DialogoNuevaAgrupacion({required this.proyectoId});

  final String proyectoId;

  @override
  State<_DialogoNuevaAgrupacion> createState() => _DialogoNuevaAgrupacionState();
}

class _DialogoNuevaAgrupacionState extends State<_DialogoNuevaAgrupacion> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _prefijoController = TextEditingController();
  final _pisoDesdeController = TextEditingController(text: '1');
  final _pisoHastaController = TextEditingController(text: '1');
  final _unidadesController = TextEditingController(text: '4');
  TipoAgrupacion _tipo = TipoAgrupacion.torre;

  @override
  void dispose() {
    _nombreController.dispose();
    _prefijoController.dispose();
    _pisoDesdeController.dispose();
    _pisoHastaController.dispose();
    _unidadesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final nombre = _nombreController.text.trim();

    context.read<InfraestructuraBloc>().add(
      InfraestructuraAgrupacionRegistrada(
        proyectoId: widget.proyectoId,
        nombre: nombre,
        tipo: _tipo,
        prefijo: _prefijoController.text.trim().isEmpty
            ? nombre
            : _prefijoController.text.trim(),
        pisoDesde: int.tryParse(_pisoDesdeController.text) ?? 1,
        pisoHasta: int.tryParse(_pisoHastaController.text) ?? 1,
        unidadesPorPiso: int.tryParse(_unidadesController.text) ?? 1,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva agrupación'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre (ej. Torre A)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value?.trim().isEmpty ?? true) ? 'Ingresa un nombre' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TipoAgrupacion>(
                initialValue: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo de agrupación',
                  border: OutlineInputBorder(),
                ),
                items: TipoAgrupacion.values
                    .map(
                      (tipo) => DropdownMenuItem(
                        value: tipo,
                        child: Text(switch (tipo) {
                          TipoAgrupacion.torre => 'Torre',
                          TipoAgrupacion.bloque => 'Bloque',
                          TipoAgrupacion.manzana => 'Manzana',
                        }),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _tipo = value ?? _tipo),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _prefijoController,
                decoration: const InputDecoration(
                  labelText: 'Prefijo (opcional, por defecto el nombre)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pisoDesdeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Piso desde',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          int.tryParse(value ?? '') == null ? 'Inválido' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _pisoHastaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Piso hasta',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          int.tryParse(value ?? '') == null ? 'Inválido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _unidadesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Unidades por piso',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (int.tryParse(value ?? '') ?? 0) < 1 ? 'Mínimo 1' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Registrar')),
      ],
    );
  }
}

class _DialogoNuevaAccesoria extends StatefulWidget {
  const _DialogoNuevaAccesoria({
    required this.proyectoId,
    required this.unidadPrincipal,
  });

  final String proyectoId;
  final UnidadPrincipal unidadPrincipal;

  @override
  State<_DialogoNuevaAccesoria> createState() => _DialogoNuevaAccesoriaState();
}

class _DialogoNuevaAccesoriaState extends State<_DialogoNuevaAccesoria> {
  final _identificadorController = TextEditingController();
  TipoUnidadAccesoria _tipo = TipoUnidadAccesoria.estacionamiento;
  bool _asignar = true;

  @override
  void dispose() {
    _identificadorController.dispose();
    super.dispose();
  }

  void _submit() {
    final identificador = _identificadorController.text.trim();
    if (identificador.isEmpty) return;

    context.read<InfraestructuraBloc>().add(
      InfraestructuraUnidadAccesoriaCreada(
        proyectoId: widget.proyectoId,
        identificador: identificador,
        tipo: _tipo,
        unidadPrincipalId: _asignar ? widget.unidadPrincipal.id : null,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva unidad accesoria'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _identificadorController,
            decoration: const InputDecoration(
              labelText: 'Identificador (ej. E-101)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<TipoUnidadAccesoria>(
            initialValue: _tipo,
            decoration: const InputDecoration(
              labelText: 'Tipo',
              border: OutlineInputBorder(),
            ),
            items: TipoUnidadAccesoria.values
                .map(
                  (tipo) => DropdownMenuItem(
                    value: tipo,
                    child: Text(switch (tipo) {
                      TipoUnidadAccesoria.estacionamiento => 'Estacionamiento',
                      TipoUnidadAccesoria.bodega => 'Bodega',
                    }),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _tipo = value ?? _tipo),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Asignar a esta unidad'),
            value: _asignar,
            onChanged: (value) => setState(() => _asignar = value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Registrar')),
      ],
    );
  }
}

class _DialogoAsignarAccesoria extends StatefulWidget {
  const _DialogoAsignarAccesoria({
    required this.proyectoId,
    required this.accesoria,
  });

  final String proyectoId;
  final UnidadAccesoria accesoria;

  @override
  State<_DialogoAsignarAccesoria> createState() =>
      _DialogoAsignarAccesoriaState();
}

class _DialogoAsignarAccesoriaState extends State<_DialogoAsignarAccesoria> {
  bool _asignada = false;

  @override
  void initState() {
    super.initState();
    _asignada = widget.accesoria.unidadPrincipalId != null;
  }

  void _submit() {
    context.read<InfraestructuraBloc>().add(
      InfraestructuraAccesoriaAsignada(
        proyectoId: widget.proyectoId,
        unidadAccesoriaId: widget.accesoria.id,
        unidadPrincipalId: _asignada ? widget.accesoria.unidadPrincipalId : null,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Accesoria ${widget.accesoria.identificador}'),
      content: Text(
        _asignada
            ? '¿Deseas liberarla (pasa a libre disposición)?'
            : 'No está asignada a ninguna unidad principal. La asignación a '
                'otra unidad se realiza desde esa unidad.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        if (_asignada)
          FilledButton(
            onPressed: _submit,
            child: const Text('Liberar'),
          ),
      ],
    );
  }
}
