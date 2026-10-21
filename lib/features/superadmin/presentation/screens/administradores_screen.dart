import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/administradores_bloc.dart';

class AdministradoresScreen extends StatelessWidget {
  const AdministradoresScreen({super.key});

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
          if (state.administradores.isEmpty &&
              !state.cargando &&
              state.mensaje == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<AdministradoresBloc>().add(
                const AdministradoresSolicitados(),
              );
            });
          }

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
                      subtitle: Text(administrador.correo),
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
  bool _obscure = true;

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
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      border: OutlineInputBorder(),
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
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(),
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
                    decoration: InputDecoration(
                      labelText: 'Contraseña (mín. 8 caracteres)',
                      border: const OutlineInputBorder(),
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
