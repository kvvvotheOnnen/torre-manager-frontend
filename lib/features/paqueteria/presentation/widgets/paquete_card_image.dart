import 'package:flutter/material.dart';

class PaqueteCardImage extends StatelessWidget {
  const PaqueteCardImage({super.key, required this.fotoUrl, this.height});

  final String? fotoUrl;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (fotoUrl == null || fotoUrl!.isEmpty) {
      return _placeholder(context, Icons.inventory_2_outlined);
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Image.network(
          fotoUrl!,
          width: double.infinity,
          height: height,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : _placeholder(context, Icons.image_outlined),
          errorBuilder: (context, error, stackTrace) =>
              _placeholder(context, Icons.broken_image_outlined),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context, IconData icon) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      height: height,
      color: colors.surfaceContainerHighest,
      child: Icon(icon, size: 42, color: colors.primary),
    );
  }
}
