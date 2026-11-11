import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        if (state.status == AsistenteStatus.error && state.mensajeError != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.mensajeError!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('IA'),
          actions: [
            IconButton(
              tooltip: 'Cerrar sesión',
              icon: const Icon(Icons.logout),
              onPressed: () =>
                  context.read<AuthBloc>().add(const LogoutRequested()),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<AsistenteBloc, AsistenteState>(
                builder: (context, state) {
                  if (state.mensajes.isEmpty) {
                    return _MensajeInicial();
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.mensajes.length,
                    itemBuilder: (context, index) {
                      return _BurbujaMensaje(mensaje: state.mensajes[index]);
                    },
                  );
                },
              ),
            ),
            BlocBuilder<AsistenteBloc, AsistenteState>(
              builder: (context, state) {
                final enviando = state.status == AsistenteStatus.enviando;

                return SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            minLines: 1,
                            maxLines: 4,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => enviando ? null : _enviar(),
                            decoration: InputDecoration(
                              hintText: 'Escribe tu consulta sobre el reglamento…',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton.filled(
                          onPressed: enviando ? null : _enviar,
                          icon: enviando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.send),
                          tooltip: 'Enviar',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Container(
              width: double.infinity,
              color: theme.colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: Text(
                'Las respuestas se basan únicamente en el documento cargado por la administración.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MensajeInicial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Consulta el reglamento del edificio',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Pregunta por horarios, zonas seguras, retiro de vidrio o cajas, tarifas y más.',
              textAlign: TextAlign.center,
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
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: esUsuario
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(esUsuario ? 16 : 4),
            bottomRight: Radius.circular(esUsuario ? 4 : 16),
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
              const SizedBox(height: 10),
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
