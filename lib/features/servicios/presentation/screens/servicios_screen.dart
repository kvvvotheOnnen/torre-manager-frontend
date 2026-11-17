import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../dashboard/domain/entities/funcion_dashboard.dart';
import '../../../dashboard/presentation/bloc/funciones_dashboard_bloc.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Servicios recomendados')),
      floatingActionButton: puedeGestionar
          ? FloatingActionButton.extended(
              onPressed: () => _abrirFormulario(),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo servicio'),
            )
          : null,
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
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ServiciosBloc>().add(const ServiciosSolicitados());
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextField(
                  controller: _busqueda,
                  decoration: InputDecoration(
                    labelText: 'Buscar por nombre, empresa, tipo o descripción',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _busqueda.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpiar búsqueda',
                            onPressed: () {
                              _busqueda.clear();
                              context.read<ServiciosBloc>().add(
                                const BusquedaServiciosCambiada(''),
                              );
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
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
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Todos'),
                      selected: state.tipo == null,
                      onSelected: (_) => context.read<ServiciosBloc>().add(
                        const FiltroServicioCambiado(null),
                      ),
                    ),
                    ...TipoServicio.values.map(
                      (tipo) => ChoiceChip(
                        label: Text(tipo.etiqueta),
                        selected: state.tipo == tipo,
                        onSelected: (_) => context.read<ServiciosBloc>().add(
                          FiltroServicioCambiado(tipo),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (state.cargando && state.trabajadores.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.tieneError && state.trabajadores.isEmpty)
                  _Aviso(
                    icono: Icons.error_outline,
                    titulo: 'No se pudieron cargar los servicios',
                    detalle: state.mensaje,
                    accion: FilledButton(
                      onPressed: () => context.read<ServiciosBloc>().add(
                        const ServiciosSolicitados(),
                      ),
                      child: const Text('Reintentar'),
                    ),
                  )
                else if (state.sinResultados)
                  const _Aviso(
                    icono: Icons.handyman_outlined,
                    titulo: 'Sin trabajadores para mostrar',
                    detalle:
                        'Prueba con otro filtro o pide a la administración que agregue servicios.',
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columnas = constraints.maxWidth >= 1100
                          ? 3
                          : (constraints.maxWidth >= 720 ? 2 : 1);
                      const separacion = 16.0;
                      final ancho =
                          (constraints.maxWidth - separacion * (columnas - 1)) /
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
                                      ? () => _confirmarEliminacion(trabajador)
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
    this.detalle,
    this.accion,
  });

  final IconData icono;
  final String titulo;
  final String? detalle;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(icono, size: 48),
          const SizedBox(height: 12),
          Text(titulo, style: textos.titleMedium, textAlign: TextAlign.center),
          if (detalle != null) ...[
            const SizedBox(height: 6),
            Text(detalle!, textAlign: TextAlign.center),
          ],
          if (accion != null) ...[const SizedBox(height: 16), accion!],
        ],
      ),
    );
  }
}
