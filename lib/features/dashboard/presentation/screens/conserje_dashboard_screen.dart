import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import 'modulo_proximamente_screen.dart';

/// Módulo preventivo del conserje (no viene del backend todavía).
class _ModuloConserje {
  const _ModuloConserje({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.ruta,
  });

  final String id;
  final String titulo;
  final String descripcion;
  final IconData icono;
  final String ruta;
}

const _modulosConserje = <_ModuloConserje>[
  _ModuloConserje(
    id: 'paqueteria',
    titulo: 'Paquetería',
    descripcion: 'Avisos y retiro de paquetes',
    icono: Icons.inventory_2_outlined,
    ruta: AppRoutes.paqueteriaGestion,
  ),
  _ModuloConserje(
    id: 'control_acceso',
    titulo: 'Control de acceso',
    descripcion: 'Visitantes que entraron y accesos de personas de confianza',
    icono: Icons.badge_outlined,
    ruta: '/admin/modulos/control_acceso',
  ),
  _ModuloConserje(
    id: 'alertas_noticias',
    titulo: 'Alertas y noticias',
    descripcion: 'Comunicados a la comunidad',
    icono: Icons.campaign_outlined,
    ruta: '/admin/modulos/alertas_noticias',
  ),
  _ModuloConserje(
    id: 'instalaciones_extra',
    titulo: 'Reserva de espacios comunes',
    descripcion: 'Reserva de espacios comunes',
    icono: Icons.event_available_outlined,
    ruta: '/admin/modulos/instalaciones_extra',
  ),
];

class ConserjeDashboardScreen extends StatefulWidget {
  const ConserjeDashboardScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<ConserjeDashboardScreen> createState() => _ConserjeDashboardScreenState();
}

class _ConserjeDashboardScreenState extends State<ConserjeDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esEscritorio = constraints.maxWidth >= 900;

        if (esEscritorio) {
          return Scaffold(
            body: Row(
              children: [
                const _PanelModulosConserje(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PanelSuperiorConserje(
                        usuario: widget.usuario,
                        esCompacto: false,
                      ),
                      Expanded(
                        child: _ContenidoConserje(usuario: widget.usuario),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

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
          drawer: const Drawer(
            child: SafeArea(child: _PanelModulosConserje(esDrawer: true)),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PanelSuperiorConserje(
                usuario: widget.usuario,
                esCompacto: true,
                mostrarCerrarSesion: false,
              ),
              Expanded(child: _ContenidoConserje(usuario: widget.usuario)),
            ],
          ),
        );
      },
    );
  }
}

class _PanelSuperiorConserje extends StatelessWidget {
  const _PanelSuperiorConserje({
    required this.usuario,
    required this.esCompacto,
    this.mostrarCerrarSesion = true,
  });

  final Usuario usuario;
  final bool esCompacto;
  final bool mostrarCerrarSesion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nombre = Text(
      'Bienvenido, ${usuario.nombre}',
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: esCompacto
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: nombre),
                    if (mostrarCerrarSesion)
                      IconButton(
                        tooltip: 'Cerrar sesión',
                        icon: const Icon(Icons.logout),
                        onPressed: () => context.read<AuthBloc>().add(
                          const LogoutRequested(),
                        ),
                      ),
                  ],
                ),
              ],
            )
          : Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 48),
                    child: nombre,
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (mostrarCerrarSesion)
                        IconButton(
                          tooltip: 'Cerrar sesión',
                          icon: const Icon(Icons.logout),
                          onPressed: () =>
                              context.read<AuthBloc>().add(const LogoutRequested()),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _PanelModulosConserje extends StatelessWidget {
  const _PanelModulosConserje({this.esDrawer = false});

  final bool esDrawer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      child: SizedBox(
        width: esDrawer ? null : 280,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Icon(Icons.apartment_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Torre Manager',
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _TituloSeccion(texto: 'Módulos'),
                  ..._modulosConserje.map(
                    (modulo) => _ItemModuloConserje(modulo: modulo),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Text(
        texto.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ItemModuloConserje extends StatelessWidget {
  const _ItemModuloConserje({required this.modulo});

  final _ModuloConserje modulo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaffold = Scaffold.maybeOf(context);

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      leading: Icon(modulo.icono, color: theme.colorScheme.primary),
      title: Text(modulo.titulo, overflow: TextOverflow.ellipsis),
      onTap: () {
        if (scaffold?.isDrawerOpen ?? false) {
          scaffold!.closeDrawer();
        }
        context.push(
          modulo.ruta,
          extra: ProximamenteArgs(
            titulo: modulo.titulo,
            descripcion: modulo.descripcion,
          ),
        );
      },
    );
  }
}

class _ContenidoConserje extends StatelessWidget {
  const _ContenidoConserje({required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth;
        final columnas = ancho >= 1100
            ? 4
            : ancho >= 760
            ? 3
            : ancho >= 520
            ? 2
            : 1;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Panel de conserje',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hola, ${usuario.nombre}. Estos son los módulos disponibles para ti.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _modulosConserje.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnas,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.35,
                  ),
                  itemBuilder: (context, index) {
                    final modulo = _modulosConserje[index];
                    return _TarjetaModuloConserje(modulo: modulo);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TarjetaModuloConserje extends StatelessWidget {
  const _TarjetaModuloConserje({required this.modulo});

  final _ModuloConserje modulo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(
          modulo.ruta,
          extra: ProximamenteArgs(
            titulo: modulo.titulo,
            descripcion: modulo.descripcion,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(modulo.icono, size: 32, color: theme.colorScheme.primary),
                  const Spacer(),
                ],
              ),
              const Spacer(),
              Text(
                modulo.titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
