import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Descriptor de un módulo visible en el dashboard.
class _Modulo {
  const _Modulo({
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.ruta,
  });

  final String titulo;
  final String descripcion;
  final IconData icono;
  final String ruta;
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.usuario});

  final Usuario usuario;

  /// Define qué módulos ve cada rol. Es el único punto a editar cuando se
  /// agreguen módulos nuevos por perfil.
  List<_Modulo> _modulosPara(Rol rol) {
    const infraestructura = _Modulo(
      titulo: 'Infraestructura',
      descripcion: 'Proyecto, agrupaciones, unidades principales y accesorias',
      icono: Icons.domain,
      ruta: '/admin/infraestructura',
    );
    const gestionProyectos = _Modulo(
      titulo: 'Gestión de Proyectos',
      descripcion: 'Proyectos (condominios) de la plataforma y sus conteos',
      icono: Icons.apartment,
      ruta: '/superadmin/proyectos',
    );

    return switch (rol) {
      Rol.superadmin => const [gestionProyectos, infraestructura],
      Rol.administrador => const [infraestructura],
      Rol.residente => const [],
      Rol.conserje => const [],
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modulos = _modulosPara(usuario.rol);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Torre Manager'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(const LogoutRequested()),
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
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Chip(
              avatar: const Icon(Icons.badge_outlined, size: 18),
              label: Text(usuario.rol.name.toUpperCase()),
            ),
            const SizedBox(height: 24),
            if (modulos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.hourglass_empty, size: 48),
                      SizedBox(height: 12),
                      Text('Aún no tienes módulos asignados.'),
                    ],
                  ),
                ),
              )
            else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: modulos
                    .map(
                      (modulo) => _ModuloCard(
                        modulo: modulo,
                        onTap: () => context.push(modulo.ruta),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _ModuloCard extends StatelessWidget {
  const _ModuloCard({required this.modulo, required this.onTap});

  final _Modulo modulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(modulo.icono, size: 36, color: theme.colorScheme.primary),
              const Spacer(),
              Text(
                modulo.titulo,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                modulo.descripcion,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
