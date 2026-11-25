import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/app_content.dart';
import '../../../../core/widgets/app_scroll_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../domain/entities/mi_informacion.dart';
import '../bloc/residente_mi_informacion_bloc.dart';
import '../widgets/credencial_residente_card.dart';
import '../widgets/unidad_vinculada_card.dart';

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

  void _volver() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.dashboard);
  }

  void _recargar() {
    context.read<ResidenteMiInformacionBloc>().add(
      const ResidenteMiInformacionSolicitada(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _volver,
        ),
        title: const Text('Mi información'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(const LogoutRequested()),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body:
          BlocBuilder<ResidenteMiInformacionBloc, ResidenteMiInformacionState>(
            builder: (context, state) {
              final info = state.informacion;
              final cargando =
                  state.status == ResidenteMiInformacionStatus.cargando ||
                  state.status == ResidenteMiInformacionStatus.inicial;

              if (cargando && info == null) {
                return const _CargandoMiInformacion();
              }

              if (state.status == ResidenteMiInformacionStatus.error &&
                  info == null) {
                return Center(
                  child: AppEmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: 'No pudimos cargar tu información',
                    message:
                        state.mensaje ??
                        'Revisa tu conexión e inténtalo nuevamente.',
                    actionLabel: 'Reintentar',
                    onAction: _recargar,
                  ),
                );
              }

              return AppContent(
                maxWidth: 760,
                child: RefreshIndicator(
                  onRefresh: () async => _recargar(),
                  child: AppScrollView(
                    children: [
                      CredencialResidenteCard(
                        usuario: widget.usuario,
                        unidad: info?.unidadPrincipal,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _UnidadesSection(unidades: info?.unidades ?? const []),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}

class _UnidadesSection extends StatelessWidget {
  const _UnidadesSection({required this.unidades});

  final List<UnidadVinculada> unidades;

  List<UnidadVinculada> get _ordenadas {
    final copia = [...unidades];
    copia.sort((a, b) {
      if (a.esActual != b.esActual) return a.esActual ? -1 : 1;
      final fa = DateTime.tryParse(a.fechaInicio ?? '');
      final fb = DateTime.tryParse(b.fechaInicio ?? '');
      if (fa == null && fb == null) return 0;
      if (fa == null) return 1;
      if (fb == null) return -1;
      return fb.compareTo(fa);
    });
    return copia;
  }

  @override
  Widget build(BuildContext context) {
    final activas = unidades.where((u) => u.esActual).length;
    final historicas = unidades.length - activas;
    final ordenadas = _ordenadas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Unidades vinculadas',
          subtitle: historicas == 0
              ? '$activas ${activas == 1 ? 'activa' : 'activas'}'
              : '$activas activas · $historicas históricas',
        ),
        const SizedBox(height: AppSpacing.sm),
        if (ordenadas.isEmpty)
          const AppEmptyState(
            icon: Icons.apartment_outlined,
            title: 'Aún no tienes unidades vinculadas',
            message: 'Cuando la administración asocie una unidad a tu cuenta, aparecerá aquí.',
          )
        else
          for (var i = 0; i < ordenadas.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            UnidadVinculadaCard(unidad: ordenadas[i]),
          ],
      ],
    );
  }
}

class _CargandoMiInformacion extends StatelessWidget {
  const _CargandoMiInformacion();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    Widget bloque({double? height, double? width}) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: p.surfaceStrong.withValues(alpha: 0.5),
          borderRadius: AppRadii.mdAll,
        ),
      );
    }

    return AppContent(
      maxWidth: 760,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            bloque(height: 116),
            const SizedBox(height: AppSpacing.xl),
            bloque(height: 180),
            const SizedBox(height: AppSpacing.xl),
            bloque(height: 140),
          ],
        ),
      ),
    );
  }
}
