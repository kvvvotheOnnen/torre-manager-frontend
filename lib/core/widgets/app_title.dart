import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Actualiza el título del documento/navegador por pantalla.
class AppTitle extends StatelessWidget {
  const AppTitle({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'Torre Manager · $title',
      color: context.palette.primary,
      child: child,
    );
  }
}
