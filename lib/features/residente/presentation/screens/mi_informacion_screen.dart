import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/residente_mi_informacion_bloc.dart';

class MiInformacionScreen extends StatefulWidget {
  const MiInformacionScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<MiInformacionScreen> createState() => _MiInformacionScreenState();
}

class _MiInformacionScreenState extends State<MiInformacionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ResidenteMiInformacionBloc>().add(
        const ResidenteMiInformacionSolicitada(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi información'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(const LogoutRequested()),
          ),
        ],
      ),
      body: BlocBuilder<ResidenteMiInformacionBloc,
          ResidenteMiInformacionState>(
        builder: (context, state) {
          if (state.status == ResidenteMiInformacionStatus.cargando ||
              state.status == ResidenteMiInformacionStatus.inicial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ResidenteMiInformacionStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                    const SizedBox(height: 12),
                    Text(
                      state.mensaje ?? 'No fue posible cargar la información.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context
                          .read<ResidenteMiInformacionBloc>()
                          .add(const ResidenteMiInformacionSolicitada()),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final info = state.informacion;
          if (info == null) {
            return const Center(child: Text('Sin información disponible.'));
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.home_outlined, size: 64, color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Mi información',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _FilaInfo(
                              icono: Icons.door_front_door_outlined,
                              etiqueta: 'Unidad',
                              valor: info.unidad,
                            ),
                            const Divider(),
                            _FilaInfo(
                              icono: Icons.domain_outlined,
                              etiqueta: 'Agrupación',
                              valor: info.agrupacion,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () => context.go(AppRoutes.dashboard),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Volver al dashboard'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilaInfo extends StatelessWidget {
  const _FilaInfo({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icono, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(etiqueta, style: theme.textTheme.labelMedium),
              Text(
                valor,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
