import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/instalacion_extra.dart';
import '../../domain/entities/modulo_sistema.dart';
import '../../domain/entities/tipo_condominio.dart';
import '../bloc/administradores_bloc.dart';
import '../bloc/superadmin_bloc.dart';

class ProyectosScreen extends StatelessWidget {
  const ProyectosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Proyectos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const _CrearProyectoScreen()),
        ),
        icon: const Icon(Icons.add_business),
        label: const Text('Proyecto'),
      ),
      body: BlocConsumer<SuperadminBloc, SuperadminState>(
        listener: (context, state) {
          if (state.mensaje != null) {
            final theme = Theme.of(context);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.mensaje!),
                  backgroundColor: state.exito
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
              );
            context.read<SuperadminBloc>().add(
              const SuperadminMensajeConsumido(),
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

          return RefreshIndicator(
            onRefresh: () async {
              context.read<SuperadminBloc>().add(const ProyectosSolicitados());
            },
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (state.cargando) const LinearProgressIndicator(),
                if (state.proyectos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: Text('No hay proyectos registrados.')),
                  ),
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

class _CrearProyectoScreen extends StatefulWidget {
  const _CrearProyectoScreen();

  @override
  State<_CrearProyectoScreen> createState() => _CrearProyectoScreenState();
}

class _CrearProyectoScreenState extends State<_CrearProyectoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();

  TipoCondominio _tipo = TipoCondominio.torres;
  final Set<ModuloSistema> _modulos = {ModuloSistema.infraestructura};
  final List<_InstalacionForm> _instalaciones = [];
  final Set<String> _adminIds = {};

  @override
  void initState() {
    super.initState();
    context.read<AdministradoresBloc>().add(const AdministradoresSolicitados());
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    for (final instalacion in _instalaciones) {
      instalacion.dispose();
    }
    super.dispose();
  }

  void _agregarInstalacion() {
    setState(() => _instalaciones.add(_InstalacionForm()));
  }

  void _quitarInstalacion(int index) {
    setState(() {
      _instalaciones.removeAt(index).dispose();
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_modulos.isEmpty) {
      _snack('Debes habilitar al menos un módulo.', error: true);
      return;
    }
    if (_adminIds.isEmpty) {
      _snack('Debes asignar al menos un administrador.', error: true);
      return;
    }

    final instalaciones = _instalaciones
        .where((form) => form.nombre.text.trim().isNotEmpty)
        .map(
          (form) => InstalacionExtra(
            nombre: form.nombre.text.trim(),
            tipo: form.tipo.text.trim().isEmpty ? null : form.tipo.text.trim(),
          ),
        )
        .toList();

    context.read<SuperadminBloc>().add(
      ProyectoCreado(
        nombre: _nombreController.text,
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text,
        tipoCondominio: _tipo,
        modulos: _modulos.toList(),
        instalaciones: instalaciones,
        adminIds: _adminIds.toList(),
      ),
    );

    Navigator.of(context).pop();
  }

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? Theme.of(context).colorScheme.error : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo proyecto')),
      body: BlocBuilder<SuperadminBloc, SuperadminState>(
        builder: (context, superadminState) {
          return BlocBuilder<AdministradoresBloc, AdministradoresState>(
            builder: (context, adminsState) {
              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del proyecto',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value?.trim().isEmpty ?? true)
                          ? 'Ingresa un nombre'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descripcionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Tipo de condominio',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<TipoCondominio>(
                      segments: TipoCondominio.values
                          .map(
                            (tipo) => ButtonSegment(
                              value: tipo,
                              label: Text(tipo.etiqueta),
                            ),
                          )
                          .toList(),
                      selected: {_tipo},
                      onSelectionChanged: (value) =>
                          setState(() => _tipo = value.first),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Módulos habilitados',
                      style: theme.textTheme.titleMedium,
                    ),
                    ...ModuloSistema.values.map(
                      (modulo) => SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(modulo.etiqueta),
                        value: _modulos.contains(modulo),
                        onChanged: (value) => setState(() {
                          if (value) {
                            _modulos.add(modulo);
                          } else {
                            _modulos.remove(modulo);
                          }
                        }),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Instalaciones extra',
                          style: theme.textTheme.titleMedium,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _agregarInstalacion,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Añadir'),
                        ),
                      ],
                    ),
                    ...List.generate(_instalaciones.length, (index) {
                      final form = _instalaciones[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: form.nombre,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre (ej. Quincho)',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: form.tipo,
                                decoration: const InputDecoration(
                                  labelText: 'Tipo',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _quitarInstalacion(index),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    Text(
                      'Administradores con acceso',
                      style: theme.textTheme.titleMedium,
                    ),
                    if (adminsState.cargando)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: LinearProgressIndicator(),
                      ),
                    if (!adminsState.cargando &&
                        adminsState.administradores.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'No hay administradores. Crea al menos uno en el '
                          'módulo "Administradores".',
                        ),
                      ),
                    ...adminsState.administradores.map(
                      (administrador) => CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _adminIds.contains(administrador.id),
                        title: Text(administrador.nombre),
                        subtitle: Text(administrador.correo),
                        onChanged: (value) => setState(() {
                          if (value == true) {
                            _adminIds.add(administrador.id);
                          } else {
                            _adminIds.remove(administrador.id);
                          }
                        }),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed: superadminState.guardando ? null : _submit,
                        child: superadminState.guardando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Crear proyecto'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _InstalacionForm {
  final nombre = TextEditingController();
  final tipo = TextEditingController();

  void dispose() {
    nombre.dispose();
    tipo.dispose();
  }
}
