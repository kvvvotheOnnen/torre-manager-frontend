import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/domain/entities/funcion_dashboard.dart';
import 'app_router.dart';

/// Traduce una función del catálogo a su pantalla.
///
/// Las funciones sin pantalla todavía muestran un aviso en lugar de romper la
/// navegación, de modo que agregar una función al catálogo del backend no
/// obliga a tocar los dashboards.
void abrirFuncionDashboard(BuildContext context, FuncionDashboard funcion) {
  switch (funcion.ruta) {
    case AppRoutes.servicios:
      context.push(AppRoutes.servicios);
    case AppRoutes.marketplace:
      context.push(AppRoutes.marketplace);
    default:
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('${funcion.titulo}: próximamente.')),
        );
  }
}
