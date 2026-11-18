import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../dashboard/domain/entities/funcion_dashboard.dart';
import '../../../dashboard/presentation/bloc/funciones_dashboard_bloc.dart';
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

    return BlocListener<FuncionesDashboardBloc, FuncionesDashboardState>(
      listenWhen: (anterior, actual) => anterior.funciones != actual.funciones,
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
          final theme = Theme.of(context);

          return Scaffold(
            appBar: AppBar(title: const Text('Marketplace')),
            floatingActionButton: puedePublicar
                ? FloatingActionButton.extended(
                    onPressed: state.ocupado ? null : _abrirFormulario,
                    icon: state.ocupado
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add),
                    label: Text(state.ocupado ? 'Procesando...' : 'Publicar'),
                  )
                : null,
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<MarketplaceBloc>().add(
                  const MarketplaceSolicitadas(),
                );
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    controller: _busqueda,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Buscar por nombre o descripción',
                      border: const OutlineInputBorder(),
                      suffixIcon: state.busqueda.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Limpiar búsqueda',
                              onPressed: () {
                                _busqueda.clear();
                                context.read<MarketplaceBloc>().add(
                                  const BusquedaMarketplaceCambiada(''),
                                );
                              },
                              icon: const Icon(Icons.clear),
                            ),
                    ),
                    onChanged: (texto) => context.read<MarketplaceBloc>().add(
                      BusquedaMarketplaceCambiada(texto),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (puedeGestionar) ...[
                        _BotonVista(
                          icono: Icons.list_alt_outlined,
                          etiqueta: 'Todas',
                          activo:
                              state.vista == MarketplaceVista.catalogo &&
                              state.todas,
                          onPressed: () => context.read<MarketplaceBloc>().add(
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
                              state.vista == MarketplaceVista.catalogo &&
                              !state.todas,
                          onPressed: () => context.read<MarketplaceBloc>().add(
                            const VistaMarketplaceCambiada(
                              MarketplaceVista.catalogo,
                              todas: false,
                            ),
                          ),
                        ),
                        _BotonVista(
                          icono: Icons.delete_outline,
                          etiqueta: 'Eliminadas',
                          activo: state.vista == MarketplaceVista.eliminadas,
                          onPressed: () => context.read<MarketplaceBloc>().add(
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
                          activo: state.vista == MarketplaceVista.catalogo,
                          onPressed: () => context.read<MarketplaceBloc>().add(
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
                          onPressed: () => context.read<MarketplaceBloc>().add(
                            const VistaMarketplaceCambiada(
                              MarketplaceVista.mias,
                            ),
                          ),
                        ),
                      if (puedeFavoritos)
                        _BotonVista(
                          icono: Icons.favorite_border,
                          etiqueta: 'Mis favoritos',
                          activo: state.vista == MarketplaceVista.favoritos,
                          onPressed: () => context.read<MarketplaceBloc>().add(
                            const VistaMarketplaceCambiada(
                              MarketplaceVista.favoritos,
                            ),
                          ),
                        ),
                      if (puedePublicar)
                        _BotonVista(
                          icono: Icons.history,
                          etiqueta: 'Historial',
                          activo: state.vista == MarketplaceVista.historial,
                          onPressed: () => context.read<MarketplaceBloc>().add(
                            const VistaMarketplaceCambiada(
                              MarketplaceVista.historial,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Categorías', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Todas las categorías'),
                        selected: state.categoria == null,
                        onSelected: (_) => context.read<MarketplaceBloc>().add(
                          const FiltroCategoriaCambiado(null),
                        ),
                      ),
                      for (final categoria in CategoriaProducto.values)
                        ChoiceChip(
                          label: Text(categoria.etiqueta),
                          selected: state.categoria == categoria,
                          onSelected: (_) => context
                              .read<MarketplaceBloc>()
                              .add(FiltroCategoriaCambiado(categoria)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state.cargando)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.tieneError)
                    _Aviso(
                      icono: Icons.cloud_off_outlined,
                      titulo: 'No se pudo cargar el marketplace',
                      mensaje: state.mensaje ?? 'Intenta nuevamente.',
                      onAccion: () => context.read<MarketplaceBloc>().add(
                        const MarketplaceSolicitadas(),
                      ),
                    )
                  else if (state.sinResultados)
                    _Aviso(
                      icono: state.vista == MarketplaceVista.eliminadas
                          ? Icons.delete_outline
                          : Icons.storefront_outlined,
                      titulo: state.vista == MarketplaceVista.eliminadas
                          ? 'Sin publicaciones eliminadas'
                          : 'Sin publicaciones',
                      mensaje: state.vista == MarketplaceVista.eliminadas
                          ? 'Las publicaciones eliminadas por moderación aparecerán aquí.'
                          : 'No hay artículos que coincidan con el filtro.',
                      onAccion: () {
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
                            (constraints.maxWidth - (columnas - 1) * 16) /
                            columnas;

                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            for (final publicacion
                                in state.publicacionesVisibles)
                              SizedBox(
                                width: ancho,
                                child: PublicacionCard(
                                  publicacion: publicacion,
                                  procesando:
                                      state.procesandoId == publicacion.id,
                                  onAbrir: () => _abrirDetalle(publicacion),
                                  onEditar: publicacion.puedeEditar
                                      ? () => _abrirFormulario(publicacion)
                                      : null,
                                  onEliminar: publicacion.puedeEliminar
                                      ? () => _gestionarEliminacion(publicacion)
                                      : null,
                                  onFavorito:
                                      puedeFavoritos && !publicacion.esMia
                                      ? () => _alternarFavorito(publicacion)
                                      : null,
                                ),
                              ),
                          ],
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
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({
    required this.icono,
    required this.titulo,
    required this.mensaje,
    this.onAccion,
  });

  final IconData icono;
  final String titulo;
  final String mensaje;
  final VoidCallback? onAccion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(icono, size: 48, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(titulo, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          if (onAccion != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onAccion,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ],
      ),
    );
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
