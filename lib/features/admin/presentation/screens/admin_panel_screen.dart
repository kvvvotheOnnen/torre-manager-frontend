import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().add(const LogoutRequested()),
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Bienvenido, ${usuario.nombre}',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Rol: ${usuario.rol.name}', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: Icon(Icons.domain, color: theme.colorScheme.primary, size: 36),
                title: const Text('Infraestructura'),
                subtitle: const Text(
                  'Proyecto, agrupaciones, unidades principales y accesorias',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/admin/infraestructura'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
