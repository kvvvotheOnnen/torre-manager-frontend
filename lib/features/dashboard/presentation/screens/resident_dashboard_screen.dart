import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import 'modulo_proximamente_screen.dart';

/// Módulo preventivo del residente (no viene del backend todavía).
class _ModuloResidente {
  const _ModuloResidente({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.ruta,
    this.preventivo = true,
  });

  final String id;
  final String titulo;
  final String descripcion;
  final IconData icono;
  final String ruta;
  final bool preventivo;
}

const _modulosResidente = <_ModuloResidente>[
  _ModuloResidente(
    id: 'mi_informacion',
    titulo: 'Mi información',
    descripcion: 'Consulta la información que ya es del residente y asignaciones de servicio',
    icono: Icons.home_outlined,
    ruta: '/residente/mi-informacion',
    preventivo: false,
  ),
  _ModuloResidente(
    id: 'ia',
    titulo: 'IA',
    descripcion: 'Consultas sobre el reglamento de infraestructura del edificio',
    icono: Icons.star,
    ruta: '/residente/ia',
    preventivo: false,
  ),
  _ModuloResidente(
    id: 'paqueteria',
    titulo: 'Paquetería',
    descripcion: 'Avisos y retiro de paquetes',
    icono: Icons.inventory_2_outlined,
    ruta: AppRoutes.paqueteria,
    preventivo: false,
  ),
  _ModuloResidente(
    id: 'quincho',
    titulo: 'Quincho',
    descripcion: 'Reserva de espacios comunes',
    icono: Icons.event_available_outlined,
    ruta: '/admin/modulos/quincho',
  ),
  _ModuloResidente(
    id: 'gastos_comunes',
    titulo: 'Gastos comunes',
    descripcion: 'Consulta y pago de gastos comunes',
    icono: Icons.receipt_long_outlined,
    ruta: '/admin/modulos/gastos_comunes',
  ),
  _ModuloResidente(
    id: 'control_acceso',
    titulo: 'Control de acceso',
    descripcion: 'Visitantes que entraron y accesos de personas de confianza',
    icono: Icons.badge_outlined,
    ruta: '/admin/modulos/control_acceso',
  ),
];

// Las notificaciones son solo un icono en el panel superior (ver _BotonNotificaciones).

class ResidentDashboardScreen extends StatefulWidget {
  const ResidentDashboardScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<ResidentDashboardScreen> createState() => _ResidentDashboardScreenState();
}

class _ResidentDashboardScreenState extends State<ResidentDashboardScreen> {
  // Contador de notificaciones pendientes (se conectará al backend más adelante).
  // ignore: prefer_final_fields
  int _notificacionesCount = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esEscritorio = constraints.maxWidth >= 900;

        if (esEscritorio) {
          final anchoSidebar = constraints.maxWidth >= 1100 ? 280.0 : 240.0;
          return Scaffold(
            body: Row(
              children: [
                _PanelModulosResidente(anchoSidebar: anchoSidebar),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PanelSuperiorResidente(
                        usuario: widget.usuario,
                        esCompacto: false,
                        notificacionesCount: _notificacionesCount,
                      ),
                      Expanded(
                        child: _ContenidoResidente(usuario: widget.usuario),
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
            child: SafeArea(child: _PanelModulosResidente(esDrawer: true)),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PanelSuperiorResidente(
                usuario: widget.usuario,
                esCompacto: true,
                mostrarCerrarSesion: false,
                notificacionesCount: _notificacionesCount,
              ),
              Expanded(child: _ContenidoResidente(usuario: widget.usuario)),
            ],
          ),
        );
      },
    );
  }
}

class _PanelSuperiorResidente extends StatelessWidget {
  const _PanelSuperiorResidente({
    required this.usuario,
    required this.esCompacto,
    this.mostrarCerrarSesion = true,
    this.notificacionesCount = 0,
  });

  final Usuario usuario;
  final bool esCompacto;
  final bool mostrarCerrarSesion;
  final int notificacionesCount;

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
          ? Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 96),
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
                      _BotonNotificaciones(count: notificacionesCount),
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
                ),
              ],
            )
          : Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 96),
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
                      _BotonNotificaciones(count: notificacionesCount),
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

class _PanelModulosResidente extends StatelessWidget {
  const _PanelModulosResidente({this.esDrawer = false, this.anchoSidebar = 280});

  final bool esDrawer;
  final double anchoSidebar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      child: SizedBox(
        width: esDrawer ? null : anchoSidebar,
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
                  ..._modulosResidente.map(
                    (modulo) => _ItemModuloResidente(modulo: modulo),
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

class _ItemModuloResidente extends StatelessWidget {
  const _ItemModuloResidente({required this.modulo});

  final _ModuloResidente modulo;

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
        if (modulo.preventivo) {
          context.push(
            modulo.ruta,
            extra: ProximamenteArgs(
              titulo: modulo.titulo,
              descripcion: modulo.descripcion,
            ),
          );
        } else {
          context.push(modulo.ruta);
        }
      },
    );
  }
}

class _ContenidoResidente extends StatelessWidget {
  const _ContenidoResidente({required this.usuario});

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
                  'Panel de residente',
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
              itemCount: _modulosResidente.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnas,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
              ),
              itemBuilder: (context, index) {
                final modulo = _modulosResidente[index];
                return _TarjetaModuloResidente(modulo: modulo);
              },
            ),
          ],
        ), // ListView
      ), // ConstrainedBox
    ); // Center
      },
    ); // LayoutBuilder
  }
}

class _BotonNotificaciones extends StatelessWidget {
  const _BotonNotificaciones({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final icon = IconButton(
      tooltip: 'Notificaciones',
      icon: const Icon(Icons.notifications_outlined),
      onPressed: () => context.push(
        AppRoutes.adminModulo('notificaciones'),
        extra: const ProximamenteArgs(
          titulo: 'Notificaciones',
          descripcion: 'Avisos y notificaciones del recinto (próximamente)',
        ),
      ),
    );

    if (count <= 0) return icon;

    return Badge(
      label: Text('$count'),
      child: icon,
    );
  }
}

class _TarjetaModuloResidente extends StatelessWidget {
  const _TarjetaModuloResidente({required this.modulo});

  final _ModuloResidente modulo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (modulo.preventivo) {
            context.push(
              modulo.ruta,
              extra: ProximamenteArgs(
                titulo: modulo.titulo,
                descripcion: modulo.descripcion,
              ),
            );
          } else {
            context.push(modulo.ruta);
          }
        },
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
