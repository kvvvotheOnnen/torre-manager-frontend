import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../tenant/presentation/bloc/tenant_bloc.dart';
import '../../domain/entities/solicitud_residente.dart';
import '../bloc/mi_solicitud_residente_bloc.dart';

class SolicitudPendienteScreen extends StatefulWidget {
  const SolicitudPendienteScreen({super.key});

  @override
  State<SolicitudPendienteScreen> createState() =>
      _SolicitudPendienteScreenState();
}

class _SolicitudPendienteScreenState extends State<SolicitudPendienteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MiSolicitudResidenteBloc>().add(const MiSolicitudCargada());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi solicitud'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(const LogoutRequested()),
          ),
        ],
      ),
      body: BlocBuilder<MiSolicitudResidenteBloc, MiSolicitudState>(
        builder: (context, state) {
          if (state.status == MiSolicitudStatus.inicial ||
              state.status == MiSolicitudStatus.cargando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == MiSolicitudStatus.error) {
            return _EstadoCentrado(
              icono: Icons.error_outline,
              titulo: 'No fue posible consultar tu solicitud',
              mensaje: state.mensaje ?? 'Intenta nuevamente en unos minutos.',
              accion: FilledButton.icon(
                onPressed: _refrescar,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            );
          }

          final solicitud = state.ultima;

          if (solicitud == null) {
            return _EstadoCentrado(
              icono: Icons.description_outlined,
              titulo: 'No tienes una solicitud registrada',
              mensaje: 'Cuando envíes tu solicitud de ingreso, aparecerá aquí su estado.',
              accion: OutlinedButton(
                onPressed: () =>
                    context.read<AuthBloc>().add(const LogoutRequested()),
                child: const Text('Cerrar sesión'),
              ),
            );
          }

          return switch (solicitud.estado) {
            EstadoSolicitud.pendiente => _EstadoCentrado(
              icono: Icons.hourglass_top,
              titulo: 'Estamos revisando su solicitud',
              mensaje:
                  'Tu solicitud para la unidad ${solicitud.unidad} está siendo revisada por la administración.',
              color: theme.colorScheme.primary,
              accion: FilledButton.icon(
                onPressed: _refrescar,
                icon: const Icon(Icons.refresh),
                label: const Text('Actualizar'),
              ),
            ),
            EstadoSolicitud.rechazada => _EstadoCentrado(
              icono: Icons.cancel_outlined,
              titulo: 'Tu solicitud fue rechazada',
              mensaje:
                  solicitud.motivoRechazo ??
                  'La administración rechazó la solicitud para la unidad ${solicitud.unidad}.',
              color: theme.colorScheme.error,
              accion: OutlinedButton(
                onPressed: () =>
                    context.read<AuthBloc>().add(const LogoutRequested()),
                child: const Text('Cerrar sesión'),
              ),
            ),
            EstadoSolicitud.aprobada => _EstadoCentrado(
              icono: Icons.check_circle_outline,
              titulo: 'Tu solicitud fue aprobada',
              mensaje:
                  'Ya tienes acceso a la unidad ${solicitud.unidad}. Recarga para entrar al dashboard.',
              color: Colors.green,
              accion: FilledButton.icon(
                onPressed: _refrescar,
                icon: const Icon(Icons.refresh),
                label: const Text('Actualizar'),
              ),
            ),
          };
        },
      ),
    );
  }

  void _refrescar() {
    context.read<MiSolicitudResidenteBloc>().add(const MiSolicitudCargada());
    context.read<TenantBloc>().add(const TenantResuelto());
  }
}

class _EstadoCentrado extends StatelessWidget {
  const _EstadoCentrado({
    required this.icono,
    required this.titulo,
    required this.mensaje,
    this.accion,
    this.color,
  });

  final IconData icono;
  final String titulo;
  final String mensaje;
  final Widget? accion;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, size: 64, color: color ?? theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(mensaje, textAlign: TextAlign.center),
              if (accion != null) ...[const SizedBox(height: 24), accion!],
            ],
          ),
        ),
      ),
    );
  }
}
