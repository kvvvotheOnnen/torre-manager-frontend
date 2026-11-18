import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/router/funcion_rutas.dart';
import '../../../../core/theme/design_tokens.dart';
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
import '../../domain/entities/categoria_producto.dart';
import '../../domain/entities/publicacion_marketplace.dart';
import '../bloc/marketplace_bloc.dart';
import '../widgets/eliminar_publicacion_dialog.dart';
import '../widgets/opciones_publicacion_dialog.dart';
import '../widgets/publicacion_card.dart';
import '../widgets/publicacion_detalle_dialog.dart';
import '../widgets/publicacion_form_dialog.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final _busqueda = TextEditingController();
  bool _adminDetectado = false;

  @override
  void initState() {
    super.initState();

    final funciones = context.read<FuncionesDashboardBloc>();
    funciones.add(const FuncionesSolicitadas());

    final admin = _esAdmin(funciones.state);
    _adminDetectado = admin;
    context.read<MarketplaceBloc>().add(MarketplaceSolicitadas(todas: admin));
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  FuncionDashboard? _funcion(FuncionesDashboardState state) {
    for (final funcion in state.funciones) {
      if (funcion.id == 'marketplace' ||
          funcion.ruta == AppRoutes.marketplace) {
        return funcion;
      }
    }
    return null;
  }

  bool _esAdmin(FuncionesDashboardState state) {
    return _funcion(state)?.puede('gestionar') ?? false;
  }

  bool _puede(String accion) {
    final state = context.read<FuncionesDashboardBloc>().state;
    return _funcion(state)?.puede(accion) ?? false;
  }

  Future<void> _abrirFormulario([PublicacionMarketplace? publicacion]) async {
    final datos = await PublicacionFormDialog.mostrar(
      context,
      publicacion: publicacion,
    );

    if (!mounted || datos == null) {
      return;
    }

    context.read<MarketplaceBloc>().add(
      PublicacionGuardada(
        id: datos.id,
        titulo: datos.titulo,
        descripcion: datos.descripcion,
        precio: datos.precio,
        categoria: datos.categoria,
        condicion: datos.condicion,
        foto: datos.foto,
      ),
    );
  }

  Future<void> _abrirDetalle(PublicacionMarketplace publicacion) {
    final puedeFavoritos = _puede('favoritos');
    final procesando =
        context.read<MarketplaceBloc>().state.procesandoId == publicacion.id;

    return PublicacionDetalleDialog.mostrar(
      context,
      publicacion,
      onEditar: publicacion.puedeEditar && !procesando
          ? () => _abrirFormulario(publicacion)
          : null,
      onEliminar: publicacion.puedeEliminar && !procesando
          ? () => _gestionarEliminacion(publicacion)
          : null,
      onFavorito: puedeFavoritos && !publicacion.esMia && !procesando
          ? () => _alternarFavorito(publicacion)
          : null,
    );
  }

  Future<void> _gestionarEliminacion(PublicacionMarketplace publicacion) async {
    if (publicacion.esMia && publicacion.estaDisponible) {
      final accion = await OpcionesPublicacionDialog.mostrar(context);
      if (!mounted || accion == null) {
        return;
      }

      final bloc = context.read<MarketplaceBloc>();
      switch (accion) {
        case AccionPropietario.retirar:
          bloc.add(PublicacionRetiradaSolicitada(publicacion.id));
        case AccionPropietario.vender:
          bloc.add(PublicacionVendidaSolicitada(publicacion.id));
      }
      return;
    }

    final motivo = await EliminarPublicacionDialog.mostrar(
      context,
      publicacion,
    );
    if (!mounted || motivo == null) {
      return;
    }

    context.read<MarketplaceBloc>().add(
      PublicacionEliminadaSolicitada(id: publicacion.id, motivo: motivo),
    );
  }

  void _alternarFavorito(PublicacionMarketplace publicacion) {
    context.read<MarketplaceBloc>().add(
      FavoritoMarketplaceAlternado(
        id: publicacion.id,
        favorito: !publicacion.esFavorita,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FuncionesDashboardBloc>();
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
            greeting: 'Marketplace',
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
          body: BlocListener<FuncionesDashboardBloc, FuncionesDashboardState>(
            listenWhen: (anterior, actual) =>
                anterior.funciones != actual.funciones,
            listener: (context, state) {
              final admin = _esAdmin(state);
              if (admin && !_adminDetectado) {
                _adminDetectado = true;
                context.read<MarketplaceBloc>().add(
                  const MarketplaceSolicitadas(todas: true),
                );
              }
            },
            child: BlocConsumer<MarketplaceBloc, MarketplaceState>(
              listenWhen: (anterior, actual) =>
                  actual.mensaje != null && actual.mensaje != anterior.mensaje,
              listener: (context, state) {
                final mensaje = state.mensaje;
                if (mensaje == null) {
                  return;
                }

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(mensaje)));
                context.read<MarketplaceBloc>().add(
                  const MensajeMarketplaceConsumido(),
                );
              },
              builder: (context, state) {
                final puedePublicar = _puede('publicar');
                final puedeFavoritos = _puede('favoritos');
                final puedeGestionar = _puede('gestionar');

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<MarketplaceBloc>().add(
                      const MarketplaceSolicitadas(),
                    );
                  },
                  child: AppScrollView(
                    children: [
                      SectionHeader(
                        title: 'Marketplace',
                        subtitle: 'Compra y venta entre vecinos del recinto',
                        trailing: puedePublicar
                            ? FilledButton.icon(
                                onPressed: state.ocupado
                                    ? null
                                    : _abrirFormulario,
                                icon: state.ocupado
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.add_rounded),
                                label: Text(
                                  state.ocupado ? 'Procesando…' : 'Publicar',
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _busqueda,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search_rounded),
                                hintText: 'Buscar por nombre o descripción',
                                suffixIcon: state.busqueda.isEmpty
                                    ? null
                                    : IconButton(
                                        tooltip: 'Limpiar búsqueda',
                                        onPressed: () {
                                          _busqueda.clear();
                                          context.read<MarketplaceBloc>().add(
                                            const BusquedaMarketplaceCambiada(
                                              '',
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.clear_rounded),
                                      ),
                              ),
                              onChanged: (texto) =>
                                  context.read<MarketplaceBloc>().add(
                                    BusquedaMarketplaceCambiada(texto),
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                if (puedeGestionar) ...[
                                  _BotonVista(
                                    icono: Icons.list_alt_outlined,
                                    etiqueta: 'Todas',
                                    activo:
                                        state.vista ==
                                            MarketplaceVista.catalogo &&
                                        state.todas,
                                    onPressed: () => context
                                        .read<MarketplaceBloc>()
                                        .add(
                                          const VistaMarketplaceCambiada(
                                            MarketplaceVista.catalogo,
                                            todas: true,
                                          ),
                                        ),
                                  ),
                                  _BotonVista(
                                    icono: Icons.visibility_outlined,
                                    etiqueta: 'Disponibles',
                                    activo:
                                        state.vista ==
                                            MarketplaceVista.catalogo &&
                                        !state.todas,
                                    onPressed: () => context
                                        .read<MarketplaceBloc>()
                                        .add(
                                          const VistaMarketplaceCambiada(
                                            MarketplaceVista.catalogo,
                                            todas: false,
                                          ),
                                        ),
                                  ),
                                  _BotonVista(
                                    icono: Icons.delete_outline,
                                    etiqueta: 'Eliminadas',
                                    activo:
                                        state.vista ==
                                        MarketplaceVista.eliminadas,
                                    onPressed: () => context
                                        .read<MarketplaceBloc>()
                                        .add(
                                          const VistaMarketplaceCambiada(
                                            MarketplaceVista.eliminadas,
                                          ),
                                        ),
                                  ),
                                ],
                                if (puedePublicar && !puedeGestionar)
                                  _BotonVista(
                                    icono: Icons.grid_view_outlined,
                                    etiqueta: 'Catálogo',
                                    activo:
                                        state.vista ==
                                        MarketplaceVista.catalogo,
                                    onPressed: () => context
                                        .read<MarketplaceBloc>()
                                        .add(
                                          const VistaMarketplaceCambiada(
                                            MarketplaceVista.catalogo,
                                          ),
                                        ),
                                  ),
                                if (puedePublicar)
                                  _BotonVista(
                                    icono: Icons.inventory_2_outlined,
                                    etiqueta: 'Mis publicaciones',
                                    activo: state.vista == MarketplaceVista.mias,
                                    onPressed: () => context
                                        .read<MarketplaceBloc>()
                                        .add(
                                          const VistaMarketplaceCambiada(
                                            MarketplaceVista.mias,
                                          ),
                                        ),
                                  ),
                                if (puedeFavoritos)
                                  _BotonVista(
                                    icono: Icons.favorite_border,
                                    etiqueta: 'Mis favoritos',
                                    activo:
                                        state.vista ==
                                        MarketplaceVista.favoritos,
                                    onPressed: () => context
                                        .read<MarketplaceBloc>()
                                        .add(
                                          const VistaMarketplaceCambiada(
                                            MarketplaceVista.favoritos,
                                          ),
                                        ),
                                  ),
                                if (puedePublicar)
                                  _BotonVista(
                                    icono: Icons.history,
                                    etiqueta: 'Historial',
                                    activo:
                                        state.vista ==
                                        MarketplaceVista.historial,
                                    onPressed: () => context
                                        .read<MarketplaceBloc>()
                                        .add(
                                          const VistaMarketplaceCambiada(
                                            MarketplaceVista.historial,
                                          ),
                                        ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                ChoiceChip(
                                  label: const Text('Todas las categorías'),
                                  selected: state.categoria == null,
                                  onSelected: (_) => context
                                      .read<MarketplaceBloc>()
                                      .add(const FiltroCategoriaCambiado(null)),
                                ),
                                for (final categoria in CategoriaProducto.values)
                                  ChoiceChip(
                                    label: Text(categoria.etiqueta),
                                    selected: state.categoria == categoria,
                                    onSelected: (_) => context
                                        .read<MarketplaceBloc>()
                                        .add(
                                          FiltroCategoriaCambiado(categoria),
                                        ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (state.cargando)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.xxl,
                          ),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (state.tieneError)
                        AppEmptyState(
                          icon: Icons.cloud_off_outlined,
                          title: 'No se pudo cargar el marketplace',
                          message: state.mensaje ?? 'Intenta nuevamente.',
                          actionLabel: 'Reintentar',
                          onAction: () => context.read<MarketplaceBloc>().add(
                            const MarketplaceSolicitadas(),
                          ),
                        )
                      else if (state.sinResultados)
                        AppEmptyState(
                          icon: state.vista == MarketplaceVista.eliminadas
                              ? Icons.delete_outline
                              : Icons.storefront_outlined,
                          title:
                              state.vista == MarketplaceVista.eliminadas
                              ? 'Sin publicaciones eliminadas'
                              : 'Sin publicaciones',
                          message:
                              state.vista == MarketplaceVista.eliminadas
                              ? 'Las publicaciones eliminadas por moderación aparecerán aquí.'
                              : 'No hay artículos que coincidan con el filtro.',
                          actionLabel: 'Limpiar filtros',
                          onAction: () {
                            _busqueda.clear();
                            final bloc = context.read<MarketplaceBloc>();
                            bloc
                              ..add(const BusquedaMarketplaceCambiada(''))
                              ..add(const FiltroCategoriaCambiado(null));
                          },
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final columnas = constraints.maxWidth >= 1050
                                ? 3
                                : constraints.maxWidth >= 680
                                ? 2
                                : 1;
                            final ancho =
                                (constraints.maxWidth -
                                    (columnas - 1) * AppSpacing.md) /
                                columnas;

                            return Wrap(
                              spacing: AppSpacing.md,
                              runSpacing: AppSpacing.md,
                              children: [
                                for (final publicacion
                                    in state.publicacionesVisibles)
                                  SizedBox(
                                    width: ancho,
                                    child: PublicacionCard(
                                      publicacion: publicacion,
                                      procesando:
                                          state.procesandoId ==
                                          publicacion.id,
                                      onAbrir: () =>
                                          _abrirDetalle(publicacion),
                                      onEditar: publicacion.puedeEditar
                                          ? () => _abrirFormulario(
                                              publicacion,
                                            )
                                          : null,
                                      onEliminar: publicacion.puedeEliminar
                                          ? () => _gestionarEliminacion(
                                              publicacion,
                                            )
                                          : null,
                                      onFavorito:
                                          puedeFavoritos && !publicacion.esMia
                                          ? () => _alternarFavorito(
                                              publicacion,
                                            )
                                          : null,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
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

class _BotonVista extends StatelessWidget {
  const _BotonVista({
    required this.icono,
    required this.etiqueta,
    required this.activo,
    required this.onPressed,
  });

  final IconData icono;
  final String etiqueta;
  final bool activo;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (activo) {
      return FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: Icon(icono, size: 18),
        label: Text(etiqueta),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icono, size: 18),
      label: Text(etiqueta),
    );
  }
}
