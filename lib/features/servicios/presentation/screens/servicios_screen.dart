import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/router/funcion_rutas.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/app_content.dart';
import '../../../../core/widgets/app_scroll_view.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/top_bar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../dashboard/domain/entities/funcion_dashboard.dart';
import '../../../dashboard/presentation/bloc/funciones_dashboard_bloc.dart';
import '../../../dashboard/presentation/widgets/icono_funcion.dart';
import '../../domain/entities/tipo_servicio.dart';
import '../../domain/entities/trabajador_servicio.dart';
import '../bloc/servicios_bloc.dart';
import '../widgets/trabajador_servicio_card.dart';
import '../widgets/trabajador_servicio_detalle_dialog.dart';
import '../widgets/trabajador_servicio_eliminar_dialog.dart';
import '../widgets/trabajador_servicio_form_dialog.dart';

class ServiciosScreen extends StatefulWidget {
  const ServiciosScreen({super.key});

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  final _busqueda = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ServiciosBloc>().add(const ServiciosSolicitados());
    final funciones = context.read<FuncionesDashboardBloc>();
    if (funciones.state.status == FuncionesDashboardStatus.inicial) {
      funciones.add(const FuncionesSolicitadas());
    }
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  bool _puedeGestionar(BuildContext context) {
    final estado = context.watch<FuncionesDashboardBloc>().state;
    for (final FuncionDashboard funcion in estado.funciones) {
      if (funcion.id == 'servicios_recomendados' ||
          funcion.ruta == AppRoutes.servicios) {
        return funcion.puede('gestionar');
      }
    }
    return false;
  }

  Future<void> _abrirFormulario({TrabajadorServicio? inicial}) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final datos = await TrabajadorServicioFormDialog.mostrar(
      context,
      inicial: inicial,
    );
    if (datos == null || !mounted) {
      return;
    }

    context.read<ServiciosBloc>().add(
      TrabajadorGuardado(
        id: datos.id,
        nombre: datos.nombre,
        nombreEmpresa: datos.nombreEmpresa,
        telefono: datos.telefono,
        tipo: datos.tipo,
        descripcion: datos.descripcion,
        foto: datos.foto,
      ),
    );
  }

  Future<void> _confirmarEliminacion(TrabajadorServicio trabajador) async {
    final confirmado = await TrabajadorServicioEliminarDialog.mostrar(
      context,
      trabajador: trabajador,
    );

    if (confirmado && mounted) {
      context.read<ServiciosBloc>().add(
        TrabajadorEliminadoSolicitado(trabajador.id),
      );
    }
  }

  void _abrirDetalle(
    TrabajadorServicio trabajador, {
    required bool puedeGestionar,
  }) {
    TrabajadorServicioDetalleDialog.mostrar(
      context,
      trabajador: trabajador,
      onEditar: puedeGestionar
          ? () => _abrirFormulario(inicial: trabajador)
          : null,
      onEliminar: puedeGestionar
          ? () => _confirmarEliminacion(trabajador)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final puedeGestionar = _puedeGestionar(context);
    final auth = context.watch<AuthBloc>().state;
    final usuario = auth is AuthSuccess ? auth.usuario : null;
    final funciones = context.watch<FuncionesDashboardBloc>().state.funciones;
    final location = GoRouterState.of(context).matchedLocation;
    final sections = _construirSecciones(location, funciones);

    return LayoutBuilder(
      builder: (context, constraints) {
        final esEscritorio = constraints.maxWidth >= 900;
        return AppShell(
          sections: sections,
          userName: usuario?.nombre ?? '',
          roleLabel: usuario?.rol.name ?? '',
          onLogout: () => context.read<AuthBloc>().add(const LogoutRequested()),
          topBar: AppTopBar(
            greeting: 'Servicios recomendados',
            avatarName: usuario?.nombre ?? '',
            roleLabel: usuario?.rol.name,
            compact: !esEscritorio,
            showThemeToggle: !esEscritorio,
            leading: IconButton(
              tooltip: 'Volver al panel',
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.go(AppRoutes.dashboard),
            ),
            onLogout: esEscritorio
                ? null
                : () => context.read<AuthBloc>().add(const LogoutRequested()),
          ),
          body: BlocConsumer<ServiciosBloc, ServiciosState>(
            listener: (context, state) {
              final mensaje = state.mensaje;
              if (mensaje != null) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(mensaje)));
                context.read<ServiciosBloc>().add(
                  const MensajeServiciosConsumido(),
                );
              }
            },
            builder: (context, state) {
              return AppContent(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<ServiciosBloc>().add(
                      const ServiciosSolicitados(),
                    );
                  },
                  child: AppScrollView(
                    children: [
                      SectionHeader(
                        title: 'Servicios recomendados',
                        subtitle: 'Directorio de trabajadores del edificio',
                        trailing: puedeGestionar
                            ? FilledButton.icon(
                                onPressed: () => _abrirFormulario(),
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Nuevo servicio'),
                              )
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppFieldWidth(
                              child: TextField(
                                controller: _busqueda,
                                decoration: InputDecoration(
                                  labelText: 'Buscar por nombre, empresa, tipo o descripción',
                                  prefixIcon: const Icon(Icons.search_rounded),
                                  suffixIcon: _busqueda.text.isEmpty
                                      ? null
                                      : IconButton(
                                          tooltip: 'Limpiar búsqueda',
                                          onPressed: () {
                                            _busqueda.clear();
                                            context.read<ServiciosBloc>().add(
                                              const BusquedaServiciosCambiada(
                                                '',
                                              ),
                                            );
                                            setState(() {});
                                          },
                                          icon: const Icon(Icons.close_rounded),
                                        ),
                                ),
                                textInputAction: TextInputAction.search,
                                onChanged: (texto) {
                                  context.read<ServiciosBloc>().add(
                                    BusquedaServiciosCambiada(texto),
                                  );
                                  setState(() {});
                                },
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                ChoiceChip(
                                  label: const Text('Todos'),
                                  selected: state.tipo == null,
                                  onSelected: (_) => context
                                      .read<ServiciosBloc>()
                                      .add(const FiltroServicioCambiado(null)),
                                ),
                                ...TipoServicio.values.map(
                                  (tipo) => ChoiceChip(
                                    label: Text(tipo.etiqueta),
                                    selected: state.tipo == tipo,
                                    onSelected: (_) => context
                                        .read<ServiciosBloc>()
                                        .add(FiltroServicioCambiado(tipo)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (state.cargando && state.trabajadores.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.xxl,
                          ),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (state.tieneError && state.trabajadores.isEmpty)
                        AppEmptyState(
                          icon: Icons.error_outline_rounded,
                          title: 'No se pudieron cargar los servicios',
                          message: state.mensaje,
                          actionLabel: 'Reintentar',
                          onAction: () => context.read<ServiciosBloc>().add(
                            const ServiciosSolicitados(),
                          ),
                        )
                      else if (state.sinResultados)
                        const AppEmptyState(
                          icon: Icons.handyman_outlined,
                          title: 'Sin trabajadores para mostrar',
                          message: 'Prueba con otro filtro o pide a la administración que agregue servicios.',
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final columnas = constraints.maxWidth >= 1100
                                ? 3
                                : (constraints.maxWidth >= 720 ? 2 : 1);
                            const separacion = AppSpacing.md;
                            final ancho =
                                (constraints.maxWidth -
                                    separacion * (columnas - 1)) /
                                columnas;

                            return Wrap(
                              spacing: separacion,
                              runSpacing: separacion,
                              children: state.trabajadoresVisibles
                                  .map(
                                    (trabajador) => SizedBox(
                                      width: ancho,
                                      child: TrabajadorServicioCard(
                                        trabajador: trabajador,
                                        onAbrir: () => _abrirDetalle(
                                          trabajador,
                                          puedeGestionar: puedeGestionar,
                                        ),
                                        onEditar: puedeGestionar
                                            ? () => _abrirFormulario(
                                                inicial: trabajador,
                                              )
                                            : null,
                                        onEliminar: puedeGestionar
                                            ? () => _confirmarEliminacion(
                                                trabajador,
                                              )
                                            : null,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<AppNavSection> _construirSecciones(
    String location,
    List<FuncionDashboard> funciones,
  ) {
    return [
      AppNavSection(
        title: 'Navegación',
        items: [
          AppNavItem(
            label: 'Panel',
            icon: Icons.space_dashboard_outlined,
            onTap: () => context.go(AppRoutes.dashboard),
          ),
        ],
      ),
      if (funciones.isNotEmpty)
        AppNavSection(
          title: 'Comunidad',
          subtitle: 'Funciones del recinto',
          items: funciones
              .map(
                (funcion) => AppNavItem(
                  label: funcion.titulo,
                  icon: iconoDeFuncion(funcion.icono),
                  selected: location == funcion.ruta,
                  onTap: () => abrirFuncionDashboard(context, funcion),
                ),
              )
              .toList(),
        ),
    ];
  }
}
