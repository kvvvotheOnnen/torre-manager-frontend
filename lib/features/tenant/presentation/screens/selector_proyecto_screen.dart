import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/brand_mark.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../core/widgets/top_bar.dart';
import '../bloc/tenant_bloc.dart';

class SelectorProyectoScreen extends StatelessWidget {
  const SelectorProyectoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: BlocListener<TenantBloc, TenantState>(
            listenWhen: (previous, current) =>
                previous.status != current.status &&
                current.status == TenantStatus.listo,
            listener: (context, state) => context.go(AppRoutes.dashboard),
            child: BlocBuilder<TenantBloc, TenantState>(
              builder: (context, state) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.sm,
                      ),
                      child: Row(
                        children: const [
                          Expanded(
                            child: BrandMark(
                              size: 40,
                              showWordmark: true,
                              subtitle: 'SELECCIONA TU RECINTO',
                            ),
                          ),
                          ThemeToggleButton(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 920),
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: EdgeInsets.fromLTRB(
                              AppSpacing.xl,
                              AppSpacing.xl,
                              AppSpacing.xl,
                              AppSpacing.xxl +
                                  MediaQuery.viewPaddingOf(context).bottom,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.xl),
                                  decoration: BoxDecoration(
                                    gradient: p.hero,
                                    borderRadius: AppRadii.xlAll,
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.08),
                                    ),
                                    boxShadow: AppShadows.glow(p.primary),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      StatusPill(
                                        label: 'MULTI-TENANT',
                                        color: p.accent,
                                        icon: Icons.layers_rounded,
                                        compact: true,
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      Text(
                                        '¿Con qué recinto trabajas hoy?',
                                        style: theme.textTheme.headlineLarge
                                            ?.copyWith(color: Colors.white),
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      Text(
                                        'Tienes acceso a más de un recinto. '
                                        'Elige con cuál administrar.',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: Colors.white.withValues(
                                                alpha: 0.78,
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                for (final proyecto in state.proyectos) ...[
                                  GlassCard(
                                    padding: const EdgeInsets.all(
                                      AppSpacing.lg,
                                    ),
                                    onTap: () => context.read<TenantBloc>().add(
                                      TenantProyectoSeleccionado(proyecto.id),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            gradient: p.brand,
                                            borderRadius: AppRadii.mdAll,
                                            border: Border.all(
                                              color: Colors.white.withValues(
                                                alpha: 0.16,
                                              ),
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.domain_rounded,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.lg),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                proyecto.nombre,
                                                style: theme.textTheme.titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                proyecto.descripcion ??
                                                    '${proyecto.tipoCondominio.etiqueta} · '
                                                        '${proyecto.modulos.map((m) => m.etiqueta).join(', ')}',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: p.inkMuted,
                                                    ),
                                              ),
                                              if (proyecto.modulos.isNotEmpty) ...[
                                                const SizedBox(
                                                  height: AppSpacing.sm,
                                                ),
                                                Wrap(
                                                  spacing: AppSpacing.xs,
                                                  runSpacing: AppSpacing.xs,
                                                  children: proyecto.modulos
                                                      .take(4)
                                                      .map(
                                                        (modulo) => StatusPill(
                                                          label: modulo.etiqueta,
                                                          color: p.primary,
                                                          compact: true,
                                                        ),
                                                      )
                                                      .toList(),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: p.primary.withValues(
                                              alpha: 0.1,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 18,
                                            color: p.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                ],
                                if (state.proyectos.isEmpty)
                                  Text(
                                    'No hay recintos disponibles.',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: p.inkMuted,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
