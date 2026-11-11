import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../domain/entities/documento_asistente.dart';
import '../bloc/asistente_admin_bloc.dart';

class AsistenteAdminScreen extends StatefulWidget {
  const AsistenteAdminScreen({super.key});

  @override
  State<AsistenteAdminScreen> createState() => _AsistenteAdminScreenState();
}

class _AsistenteAdminScreenState extends State<AsistenteAdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AsistenteAdminBloc>().add(
        const AsistenteAdminDocumentoSolicitado(),
      );
    });
  }

  Future<void> _seleccionarPdf(BuildContext context) async {
    final archivo = await FilePicker.pickFile(
      dialogTitle: 'Selecciona el reglamento en PDF',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (archivo == null) return;

    final bytes = await archivo.readAsBytes();

    if (!context.mounted) return;
    context.read<AsistenteAdminBloc>().add(
      AsistenteAdminDocumentoSubido(bytes: bytes, nombre: archivo.name),
    );
  }

  Future<void> _confirmarEliminacion(BuildContext context) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar documento'),
        content: const Text(
          'Los residentes no podrán consultar la IA hasta que se cargue un nuevo documento. ¿Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmado == true && context.mounted) {
      context.read<AsistenteAdminBloc>().add(
        const AsistenteAdminDocumentoEliminado(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AsistenteAdminBloc, AsistenteAdminState>(
      listenWhen: (previous, current) =>
          current.mensaje != null && current.mensaje != previous.mensaje,
      listener: (context, state) {
        final mensaje = state.mensaje;
        if (mensaje == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(mensaje)));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('IA admin'),
          actions: [
            IconButton(
              tooltip: 'Cerrar sesión',
              icon: const Icon(Icons.logout),
              onPressed: () =>
                  context.read<AuthBloc>().add(const LogoutRequested()),
            ),
          ],
        ),
        body: BlocBuilder<AsistenteAdminBloc, AsistenteAdminState>(
          builder: (context, state) {
            if (state.status == AsistenteAdminStatus.cargando) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Documento de la IA',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cada proyecto puede tener un ÚNICO PDF. La IA responderá a los residentes usando exclusivamente este documento.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      if (state.documento == null)
                        _TarjetaVacia(
                          ocupado: state.ocupado,
                          onSubir: () => _seleccionarPdf(context),
                        )
                      else
                        _TarjetaDocumento(
                          documento: state.documento!,
                          ocupado: state.ocupado,
                          onEliminar: () => _confirmarEliminacion(context),
                        ),
                      if (state.ocupado) ...[
                        const SizedBox(height: 16),
                        const LinearProgressIndicator(),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TarjetaVacia extends StatelessWidget {
  const _TarjetaVacia({required this.ocupado, required this.onSubir});

  final bool ocupado;
  final VoidCallback onSubir;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay documento cargado',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sube un PDF con el reglamento de infraestructura del proyecto.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: ocupado ? null : onSubir,
              icon: const Icon(Icons.upload_file),
              label: const Text('Subir PDF'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaDocumento extends StatelessWidget {
  const _TarjetaDocumento({
    required this.documento,
    required this.ocupado,
    required this.onEliminar,
  });

  final DocumentoAsistente documento;
  final bool ocupado;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.picture_as_pdf, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    documento.nombre,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(label: Text('${documento.paginas} pág.')),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Tamaño estimado: ${documento.tamanoTokens} tokens. La IA ya puede responder consultas de los residentes de este proyecto.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: ocupado ? null : onEliminar,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Eliminar documento'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
