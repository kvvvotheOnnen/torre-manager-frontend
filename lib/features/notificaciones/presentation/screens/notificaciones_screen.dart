import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/notificacion.dart';
import '../bloc/notificaciones_bloc.dart';

class NotificacionesScreen extends StatelessWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: const [_BotonMarcarTodas()],
      ),
      body: const NotificacionesLista(),
    );
  }
}

class NotificacionesDialog extends StatelessWidget {
  const NotificacionesDialog({super.key});

  static Future<void> mostrar(BuildContext context) {
    final bloc = context.read<NotificacionesBloc>();
    bloc.add(const NotificacionesSolicitadas());

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => BlocProvider<NotificacionesBloc>.value(
        value: bloc,
        child: const NotificacionesDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alto = MediaQuery.sizeOf(context).height * 0.8;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560, maxHeight: alto),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 8, 10),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Notificaciones',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const _BotonMarcarTodas(),
                  IconButton(
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const Flexible(child: NotificacionesLista(cerrarAlAbrir: true)),
          ],
        ),
      ),
    );
  }
}

class NotificacionesLista extends StatelessWidget {
  const NotificacionesLista({super.key, this.cerrarAlAbrir = false});

  final bool cerrarAlAbrir;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificacionesBloc, NotificacionesState>(
      listenWhen: (previous, current) =>
          current.mensaje != null && current.mensaje != previous.mensaje,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.mensaje!)),
        );
        context
            .read<NotificacionesBloc>()
            .add(const MensajeNotificacionesConsumido());
      },
      builder: (context, state) {
        if (state.cargando && state.notificaciones.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.tieneError && state.notificaciones.isEmpty) {
          return AppEmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'No se pudieron cargar las notificaciones',
            message: state.mensaje,
            actionLabel: 'Reintentar',
            onAction: () => context
                .read<NotificacionesBloc>()
                .add(const NotificacionesSolicitadas()),
          );
        }

        if (state.notificaciones.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => _refrescar(context),
            child: ListView(
              children: const [
                SizedBox(height: 48),
                AppEmptyState(
                  icon: Icons.notifications_off_outlined,
                  title: 'Sin notificaciones',
                  message: 'Cuando algo importante suceda, aparecerá aquí.',
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _refrescar(context),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.notificaciones.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notificacion = state.notificaciones[index];
              return _TarjetaNotificacion(
                notificacion: notificacion,
                onTap: () => _abrirModulo(
                  context,
                  notificacion,
                  cerrarAlAbrir: cerrarAlAbrir,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _refrescar(BuildContext context) async {
    context.read<NotificacionesBloc>().add(const NotificacionesSolicitadas());
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  void _abrirModulo(
    BuildContext context,
    Notificacion notificacion, {
    required bool cerrarAlAbrir,
  }) {
    if (!notificacion.leida) {
      context
          .read<NotificacionesBloc>()
          .add(NotificacionLeidaSolicitada(notificacion.id));
    }

    final ruta = _rutaPara(context, notificacion.tipo);
    if (ruta == null) {
      return;
    }

    final router = GoRouter.of(context);
    if (cerrarAlAbrir) {
      Navigator.of(context).maybePop();
    }
    router.push(ruta);
  }

  String? _rutaPara(BuildContext context, String tipo) {
    switch (tipo) {
      case 'paqueteria':
      case 'paqueteria_recordatorio':
        return _esResidente(context)
            ? AppRoutes.paqueteria
            : AppRoutes.paqueteriaGestion;
      case 'marketplace':
        return AppRoutes.marketplace;
      case 'servicios':
        return AppRoutes.servicios;
      case 'solicitudes':
        return _esResidente(context) ? AppRoutes.solicitudPendiente : null;
      default:
        return null;
    }
  }

  bool _esResidente(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthSuccess) {
      return false;
    }
    final rol = auth.usuario.rol.name;
    return rol == 'residente' || rol == 'propietario';
  }
}

class _BotonMarcarTodas extends StatelessWidget {
  const _BotonMarcarTodas();

  @override
  Widget build(BuildContext context) {
    final noLeidas = context.watch<NotificacionesBloc>().state.noLeidas;
    if (noLeidas == 0) {
      return const SizedBox.shrink();
    }

    return TextButton(
      onPressed: () => context
          .read<NotificacionesBloc>()
          .add(const TodasNotificacionesLeidasSolicitadas()),
      child: const Text('Marcar todas'),
    );
  }
}

class _TarjetaNotificacion extends StatelessWidget {
  const _TarjetaNotificacion({required this.notificacion, this.onTap});

  final Notificacion notificacion;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notificacion.leida)
            const SizedBox(width: 18)
          else
            Container(
              margin: const EdgeInsets.only(top: 6, right: 10),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colorScheme.error,
                shape: BoxShape.circle,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notificacion.titulo,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: notificacion.leida
                        ? FontWeight.w500
                        : FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(notificacion.mensaje, style: theme.textTheme.bodyMedium),
                if (notificacion.creadoEn != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _formatearFecha(notificacion.creadoEn!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final local = fecha.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    final mes = local.month.toString().padLeft(2, '0');
    final hora = local.hour.toString().padLeft(2, '0');
    final minuto = local.minute.toString().padLeft(2, '0');
    return '$dia-$mes-${local.year} $hora:$minuto';
  }
}
