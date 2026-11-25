import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/app_content.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../domain/entities/fuente_asistente.dart';
import '../bloc/asistente_bloc.dart';

class AsistenteScreen extends StatefulWidget {
  const AsistenteScreen({super.key});

  @override
  State<AsistenteScreen> createState() => _AsistenteScreenState();
}

class _AsistenteScreenState extends State<AsistenteScreen> {
  static const String _preguntaSugerida =
      '¿En qué piso se encuentra el Quincho?';

  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _enviar() {
    final pregunta = _controller.text.trim();
    if (pregunta.isEmpty) return;

    _controller.clear();
    context.read<AsistenteBloc>().add(AsistentePreguntaEnviada(pregunta));
    _desplazarAlFinal();
  }

  void _desplazarAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AsistenteBloc, AsistenteState>(
      listenWhen: (previous, current) =>
          current.mensajes.length != previous.mensajes.length ||
          current.status != previous.status,
      listener: (context, state) {
        _desplazarAlFinal();
        if (state.status == AsistenteStatus.error &&
            state.mensajeError != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.mensajeError!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Volver al panel',
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go(AppRoutes.dashboard),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Asistente'),
              Text('Reglamento del edificio', style: theme.textTheme.bodySmall),
            ],
          ),
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
        body: AppContent(
          maxWidth: 880,
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: BlocBuilder<AsistenteBloc, AsistenteState>(
                    builder: (context, state) {
                      if (state.mensajes.isEmpty) {
                        return const _MensajeInicial();
                      }

                      final enviando = state.status == AsistenteStatus.enviando;

                      return ListView.builder(
                        controller: _scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.sm,
                        ),
                        itemCount: state.mensajes.length + (enviando ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= state.mensajes.length) {
                            return const _BurbujaEscribiendo();
                          }
                          return _BurbujaMensaje(
                            mensaje: state.mensajes[index],
                          );
                        },
                      );
                    },
                  ),
                ),
                BlocBuilder<AsistenteBloc, AsistenteState>(
                  builder: (context, state) {
                    final enviando = state.status == AsistenteStatus.enviando;

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        AppSpacing.md,
                      ),
                      child: _CompositorMensaje(
                        controller: _controller,
                        enviando: enviando,
                        onEnviar: _enviar,
                        hintText: _preguntaSugerida,
                      ),
                    );
                  },
                ),
                _AvisoReglamento(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompositorMensaje extends StatelessWidget {
  const _CompositorMensaje({
    required this.controller,
    required this.enviando,
    required this.onEnviar,
    required this.hintText,
  });

  final TextEditingController controller;
  final bool enviando;
  final VoidCallback onEnviar;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: p.border),
        boxShadow: AppShadows.soft(p.isDark),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.send,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => enviando ? null : onEnviar(),
              decoration: InputDecoration(
                hintText: hintText,
                filled: false,
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final puedeEnviar = !enviando && value.text.trim().isNotEmpty;

              return SizedBox(
                width: 44,
                height: 44,
                child: IconButton.filled(
                  onPressed: puedeEnviar ? onEnviar : null,
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    disabledBackgroundColor: p.surfaceStrong,
                    disabledForegroundColor: p.inkMuted,
                    shape: const CircleBorder(),
                  ),
                  icon: const Icon(Icons.send_rounded),
                  tooltip: 'Enviar',
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AvisoReglamento extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Text(
        'Las respuestas se basan únicamente en el documento cargado por la administración.',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 11,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _MensajeInicial extends StatelessWidget {
  const _MensajeInicial();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Consulta el reglamento del edificio',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Pregunta por horarios, zonas seguras, retiro de vidrio o cajas, tarifas y más.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BurbujaMensaje extends StatelessWidget {
  const _BurbujaMensaje({required this.mensaje});

  final MensajeAsistente mensaje;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final esUsuario = mensaje.esUsuario;

    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: esUsuario
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadii.md),
            topRight: const Radius.circular(AppRadii.md),
            bottomLeft: Radius.circular(esUsuario ? AppRadii.md : 4),
            bottomRight: Radius.circular(esUsuario ? 4 : AppRadii.md),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mensaje.texto,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: esUsuario ? theme.colorScheme.onPrimary : null,
              ),
            ),
            if (mensaje.fuentes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: mensaje.fuentes
                    .map((fuente) => _ChipFuente(fuente: fuente))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BurbujaEscribiendo extends StatefulWidget {
  const _BurbujaEscribiendo();

  @override
  State<_BurbujaEscribiendo> createState() => _BurbujaEscribiendoState();
}

class _BurbujaEscribiendoState extends State<_BurbujaEscribiendo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        label: 'El asistente está escribiendo',
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadii.md),
              topRight: Radius.circular(AppRadii.md),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(AppRadii.md),
            ),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  final inicio = index * 0.2;
                  final curva = CurvedAnimation(
                    parent: _controller,
                    curve: Interval(
                      inicio,
                      inicio + 0.6,
                      curve: Curves.easeInOut,
                    ),
                  );
                  final valor = (curva.value * 2 - 1).abs();
                  return Padding(
                    padding: EdgeInsets.only(right: index == 2 ? 0 : 5),
                    child: Transform.translate(
                      offset: Offset(0, -3 * (1 - valor)),
                      child: Opacity(
                        opacity: 0.35 + 0.65 * valor,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurfaceVariant,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ChipFuente extends StatelessWidget {
  const _ChipFuente({required this.fuente});

  final FuenteAsistente fuente;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: const Icon(Icons.menu_book_outlined, size: 16),
      label: Text('${fuente.documento} · pág. ${fuente.pagina}'),
    );
  }
}
