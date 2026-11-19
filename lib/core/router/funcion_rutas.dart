import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/domain/entities/funcion_dashboard.dart';
import '../../features/dashboard/presentation/screens/modulo_proximamente_screen.dart';
import 'app_router.dart';

/// Traduce una función del catálogo a su pantalla.
///
/// El catálogo y la autorización viven en el backend; aquí solo se decide la
/// ruta concreta del cliente. Las funciones sin pantalla todavía muestran un
/// aviso en lugar de romper la navegación.
void abrirFuncionDashboard(BuildContext context, FuncionDashboard funcion) {
  switch (funcion.ruta) {
    case AppRoutes.servicios:
      context.push(AppRoutes.servicios);
    case AppRoutes.marketplace:
      context.push(AppRoutes.marketplace);
    case AppRoutes.residenteMiInformacion:
      context.push(AppRoutes.residenteMiInformacion);
    case AppRoutes.residenteAsistente:
      context.push(AppRoutes.residenteAsistente);
    case AppRoutes.adminAsistente:
      context.push(AppRoutes.adminAsistente);
    case AppRoutes.solicitudesResidente:
      context.push(AppRoutes.solicitudesResidente);
    case AppRoutes.paqueteria:
      context.push(
        funcion.puede('gestionar')
            ? AppRoutes.paqueteriaGestion
            : AppRoutes.paqueteria,
      );
    default:
      if (funcion.ruta.startsWith('${AppRoutes.adminModulos}/')) {
        context.push(
          funcion.ruta,
          extra: ProximamenteArgs(
            titulo: funcion.titulo,
            descripcion: funcion.descripcion,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('${funcion.titulo}: próximamente.')),
        );
  }
}
