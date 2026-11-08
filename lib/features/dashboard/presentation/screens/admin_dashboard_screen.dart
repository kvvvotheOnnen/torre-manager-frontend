import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../tenant/presentation/bloc/tenant_bloc.dart';
import '../../domain/entities/modulo_dashboard.dart';
import '../bloc/modulos_dashboard_bloc.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final proyectoId = context.read<TenantBloc>().state.proyectoActivoId;
      if (proyectoId != null) {
        context.read<ModulosDashboardBloc>().add(
          const ModulosDashboardSolicitados(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TenantBloc, TenantState>(
      listenWhen: (previous, current) =>
          previous.proyectoActivoId != current.proyectoActivoId &&
          current.proyectoActivoId != null,
      listener: (context, state) {
        context.read<ModulosDashboardBloc>().add(
          const ModulosDashboardSolicitados(),
        );
      },
      child: BlocBuilder<TenantBloc, TenantState>(
        builder: (context, tenantState) {
          if (tenantState.status == TenantStatus.inicial ||
              tenantState.status == TenantStatus.cargando) {
            return const _EstadoDashboard(child: CircularProgressIndicator());
          }

          final proyecto = tenantState.proyectoActivo;
          if (proyecto == null) {
            return _EstadoDashboard(
              child: _SinProyectos(
                mensaje:
                    tenantState.mensaje ??
                    'No tienes proyectos asignados para administrar.',
                onReintentar: () =>
                    context.read<TenantBloc>().add(const TenantResuelto()),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final esEscritorio = constraints.maxWidth >= 900;
              final modulosState = context.watch<ModulosDashboardBloc>().state;

              if (esEscritorio) {
                return Scaffold(
                  body: Row(
                    children: [
                      _PanelModulos(modulosState: modulosState),
                      Expanded(
                        child: Column(
                          children: [
                            _PanelSuperior(
                              usuario: widget.usuario,
                              tenantState: tenantState,
                              esCompacto: false,
                            ),
                            Expanded(
                              child: _ContenidoDashboard(
                                usuario: widget.usuario,
                                proyectoNombre: proyecto.nombre,
                                modulosState: modulosState,
                              ),
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
                  title: Text(proyecto.nombre),
                  actions: [
                    IconButton(
                      tooltip: 'Cerrar sesión',
                      icon: const Icon(Icons.logout),
                      onPressed: () =>
                          context.read<AuthBloc>().add(const LogoutRequested()),
                    ),
                  ],
                ),
                drawer: Drawer(
                  child: SafeArea(
                    child: _PanelModulos(
                      modulosState: modulosState,
                      esDrawer: true,
                    ),
                  ),
                ),
                body: Column(
                  children: [
                    _PanelSuperior(
                      usuario: widget.usuario,
                      tenantState: tenantState,
                      esCompacto: true,
                      mostrarCerrarSesion: false,
                    ),
                    Expanded(
                      child: _ContenidoDashboard(
                        usuario: widget.usuario,
                        proyectoNombre: proyecto.nombre,
                        modulosState: modulosState,
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

class _EstadoDashboard extends StatelessWidget {
  const _EstadoDashboard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(child: child)),
    );
  }
}

class _SinProyectos extends StatelessWidget {
  const _SinProyectos({required this.mensaje, required this.onReintentar});

  final String mensaje;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.domain_disabled, size: 56),
          const SizedBox(height: 12),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onReintentar,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _PanelSuperior extends StatelessWidget {
  const _PanelSuperior({
    required this.usuario,
    required this.tenantState,
    required this.esCompacto,
    this.mostrarCerrarSesion = true,
  });

  final Usuario usuario;
  final TenantState tenantState;
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
    final selector = _SelectorProyecto(tenantState: tenantState);

    return Container(
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
                const SizedBox(height: 8),
                selector,
              ],
            )
          : Row(
              children: [
                Flexible(child: nombre),
                const SizedBox(width: 20),
                SizedBox(width: 260, child: selector),
                const Spacer(),
                if (mostrarCerrarSesion)
                  IconButton(
                    tooltip: 'Cerrar sesión',
                    icon: const Icon(Icons.logout),
                    onPressed: () =>
                        context.read<AuthBloc>().add(const LogoutRequested()),
                  ),
              ],
            ),
    );
  }
}

class _SelectorProyecto extends StatelessWidget {
  const _SelectorProyecto({required this.tenantState});

  final TenantState tenantState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final proyectoActivoId = tenantState.proyectoActivoId;

    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Proyecto activo',
        prefixIcon: Icon(Icons.apartment_outlined),
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: proyectoActivoId,
          isExpanded: true,
          isDense: true,
          style: theme.textTheme.bodyMedium,
          items: tenantState.proyectos
              .map(
                (proyecto) => DropdownMenuItem(
                  value: proyecto.id,
                  child: Text(proyecto.nombre, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (id) {
            if (id == null || id == proyectoActivoId) return;
            context.read<TenantBloc>().add(TenantProyectoSeleccionado(id));
          },
        ),
      ),
    );
  }
}

class _PanelModulos extends StatelessWidget {
  const _PanelModulos({required this.modulosState, this.esDrawer = false});

  final ModulosDashboardState modulosState;
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
                  Icon(
                    Icons.apartment_rounded,
                    color: theme.colorScheme.primary,
                  ),
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
            if (modulosState.status == ModulosDashboardStatus.cargando)
              const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  if (modulosState.modulosProyecto.isNotEmpty) ...[
                    _TituloSeccion(texto: 'Módulos del proyecto'),
                    ...modulosState.modulosProyecto.map(
                      (modulo) => _ItemModulo(
                        modulo: modulo,
                        seleccionado:
                            GoRouterState.of(context).matchedLocation ==
                            _rutaPara(modulo),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(),
                    ),
                  ],
                  if (modulosState.modulosGenerales.isNotEmpty) ...[
                    _TituloSeccion(texto: 'Módulos generales'),
                    ...modulosState.modulosGenerales.map(
                      (modulo) => _ItemModulo(
                        modulo: modulo,
                        seleccionado:
                            GoRouterState.of(context).matchedLocation ==
                            _rutaPara(modulo),
                      ),
                    ),
                  ],
                  if (modulosState.status == ModulosDashboardStatus.error)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            modulosState.mensaje ??
                                'No fue posible cargar los módulos.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () => context
                                .read<ModulosDashboardBloc>()
                                .add(const ModulosDashboardSolicitados()),
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Reintentar'),
                          ),
                        ],
                      ),
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

class _ItemModulo extends StatelessWidget {
  const _ItemModulo({required this.modulo, required this.seleccionado});

  final ModuloDashboard modulo;
  final bool seleccionado;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = modulo.habilitado
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withValues(alpha: 0.45);

    return ListTile(
      dense: true,
      selected: seleccionado,
      selectedTileColor: theme.colorScheme.secondaryContainer,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      leading: Icon(
        _iconoPara(modulo.id),
        color: modulo.habilitado ? theme.colorScheme.primary : color,
      ),
      title: Text(
        modulo.nombre,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: color),
      ),
      trailing: modulo.habilitado
          ? null
          : Icon(Icons.lock_outline, size: 18, color: color),
      onTap: () => _abrirModulo(context, modulo),
    );
  }
}

class _ContenidoDashboard extends StatelessWidget {
  const _ContenidoDashboard({
    required this.usuario,
    required this.proyectoNombre,
    required this.modulosState,
  });

  final Usuario usuario;
  final String proyectoNombre;
  final ModulosDashboardState modulosState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (modulosState.status == ModulosDashboardStatus.cargando &&
        modulosState.modulos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (modulosState.status == ModulosDashboardStatus.error &&
        modulosState.modulos.isEmpty) {
      return Center(
        child: _SinProyectos(
          mensaje: modulosState.mensaje ?? 'No fue posible cargar los módulos.',
          onReintentar: () => context.read<ModulosDashboardBloc>().add(
            const ModulosDashboardSolicitados(),
          ),
        ),
      );
    }

    final modulos = modulosState.modulos;

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

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Panel de $proyectoNombre',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hola, ${usuario.nombre}. Estos son los módulos disponibles para este proyecto.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: modulos.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnas,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
              ),
              itemBuilder: (context, index) {
                final modulo = modulos[index];
                return _TarjetaModulo(modulo: modulo);
              },
            ),
          ],
        );
      },
    );
  }
}

class _TarjetaModulo extends StatelessWidget {
  const _TarjetaModulo({required this.modulo});

  final ModuloDashboard modulo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habilitado = modulo.habilitado;
    final color = habilitado
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withValues(alpha: 0.45);

    return Card(
      clipBehavior: Clip.antiAlias,
      color: habilitado ? null : theme.colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () => _abrirModulo(context, modulo),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _iconoPara(modulo.id),
                    size: 32,
                    color: habilitado ? theme.colorScheme.primary : color,
                  ),
                  const Spacer(),
                  if (!habilitado)
                    Icon(Icons.lock_outline, size: 20, color: color),
                ],
              ),
              const Spacer(),
              Text(
                modulo.nombre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                habilitado
                    ? modulo.descripcion
                    : 'No habilitado para este proyecto.',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _abrirModulo(BuildContext context, ModuloDashboard modulo) {
  if (!modulo.habilitado) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Este módulo no está habilitado para el proyecto.'),
        ),
      );
    return;
  }

  final scaffold = Scaffold.maybeOf(context);
  if (scaffold?.isDrawerOpen ?? false) {
    scaffold!.closeDrawer();
  }

  final ruta = _rutaPara(modulo);
  if (GoRouterState.of(context).matchedLocation == ruta) return;
  context.push(ruta);
}

String _rutaPara(ModuloDashboard modulo) {
  return AppRoutes.adminModulo(modulo.id);
}

IconData _iconoPara(String id) {
  return switch (id) {
    'paqueteria' => Icons.inventory_2_outlined,
    'instalaciones_extra' => Icons.event_available_outlined,
    'gastos_comunes' => Icons.receipt_long,
    'control_acceso' => Icons.security,
    'registro_conserjes' => Icons.badge_outlined,
    'cambio_unidad_residente' => Icons.swap_horiz,
    'solicitudes_residente' => Icons.how_to_reg_outlined,
    'registro_empleados' => Icons.cleaning_services_outlined,
    'personas_externas_oficios' => Icons.engineering_outlined,
    'alertas_noticias' => Icons.campaign_outlined,
    _ => Icons.widgets_outlined,
  };
}
