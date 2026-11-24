import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/administradores_bloc.dart';
import '../bloc/superadmin_bloc.dart';

class AdministradoresScreen extends StatefulWidget {
  const AdministradoresScreen({super.key});

  @override
  State<AdministradoresScreen> createState() => _AdministradoresScreenState();
}

class _AdministradoresScreenState extends State<AdministradoresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final bloc = context.read<AdministradoresBloc>();
      final state = bloc.state;
      if (state.administradores.isEmpty && !state.cargando) {
        bloc.add(const AdministradoresSolicitados());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administradores')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirDialogo(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Administrador'),
      ),
      body: BlocConsumer<AdministradoresBloc, AdministradoresState>(
        listener: (context, state) {
          if (state.exito) {
            Navigator.of(context, rootNavigator: true).maybePop();
          }
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
            context.read<AdministradoresBloc>().add(
              const AdministradoresMensajeConsumido(),
            );
          }
        },
        builder: (context, state) {
          if (state.cargando && state.administradores.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AdministradoresBloc>().add(
                const AdministradoresSolicitados(),
              );
            },
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (state.cargando) const LinearProgressIndicator(),
                if (state.administradores.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Text('Aún no hay administradores registrados.'),
                    ),
                  ),
                ...state.administradores.map(
                  (administrador) => Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.admin_panel_settings),
                      ),
                      title: Text(administrador.nombre),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(administrador.correo),
                          if (administrador.proyectos.isEmpty)
                            const Text(
                              'Sin proyecto asignado',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            )
                          else
                            Text(
                              administrador.proyectos
                                  .map((proyecto) => proyecto.nombre)
                                  .join(', '),
                            ),
                        ],
                      ),
                      isThreeLine: true,
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

  void _abrirDialogo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => const _DialogoNuevoAdministrador(),
    );
  }
}

class _DialogoNuevoAdministrador extends StatefulWidget {
  const _DialogoNuevoAdministrador();

  @override
  State<_DialogoNuevoAdministrador> createState() =>
      _DialogoNuevoAdministradorState();
}

class _DialogoNuevoAdministradorState
    extends State<_DialogoNuevoAdministrador> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final Set<String> _proyectosSeleccionados = {};
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    final superadmin = context.read<SuperadminBloc>();
    if (superadmin.state.proyectos.isEmpty && !superadmin.state.cargando) {
      superadmin.add(const ProyectosSolicitados());
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AdministradoresBloc>().add(
      AdministradorCreado(
        nombre: _nombreController.text,
        correo: _correoController.text,
        password: _passwordController.text,
        proyectoIds: _proyectosSeleccionados.toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdministradoresBloc, AdministradoresState>(
      builder: (context, state) {
        return AlertDialog(
          title: const Text('Nuevo administrador'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nombreController,
                    enabled: !state.guardando,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                    ),
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? 'Ingresa un nombre'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _correoController,
                    enabled: !state.guardando,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) return 'Ingresa un correo';
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(email)) {
                        return 'Correo inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    enabled: !state.guardando,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Contraseña (mín. 8 caracteres)',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (value) =>
                        (value ?? '').length < 8 ? 'Mínimo 8 caracteres' : null,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Proyectos (opcional)',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Anexa la cuenta a uno o más proyectos. Puedes hacerlo '
                      'también luego desde la edición del proyecto.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 4),
                  BlocBuilder<SuperadminBloc, SuperadminState>(
                    builder: (context, superadminState) {
                      if (superadminState.proyectos.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            superadminState.cargando
                                ? 'Cargando proyectos...'
                                : 'No hay proyectos disponibles.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      }

                      return ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 180),
                        child: SingleChildScrollView(
                          child: Column(
                            children: superadminState.proyectos
                                .map(
                                  (proyecto) => CheckboxListTile(
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    value: _proyectosSeleccionados.contains(
                                      proyecto.id,
                                    ),
                                    title: Text(proyecto.nombre),
                                    onChanged: state.guardando
                                        ? null
                                        : (value) => setState(() {
                                            if (value ?? false) {
                                              _proyectosSeleccionados.add(
                                                proyecto.id,
                                              );
                                            } else {
                                              _proyectosSeleccionados.remove(
                                                proyecto.id,
                                              );
                                            }
                                          }),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: state.guardando
                  ? null
                  : () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: state.guardando ? null : _submit,
              child: state.guardando
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Registrar'),
            ),
          ],
        );
      },
    );
  }
}
