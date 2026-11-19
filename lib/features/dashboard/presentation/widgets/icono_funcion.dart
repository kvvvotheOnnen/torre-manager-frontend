import 'package:flutter/material.dart';

/// Traduce el nombre de ícono que envía el backend en el catálogo de funciones.
IconData iconoDeFuncion(String nombre) {
  return switch (nombre) {
    'badge' => Icons.badge_outlined,
    'campaign' => Icons.campaign_outlined,
    'domain' => Icons.domain_outlined,
    'event' => Icons.event_available_outlined,
    'handyman' => Icons.handyman_outlined,
    'payments' => Icons.payments_outlined,
    'package' => Icons.inventory_2_outlined,
    'storefront' => Icons.storefront_outlined,
    'info' => Icons.info_outline,
    'star' => Icons.auto_awesome_outlined,
    'security' => Icons.security_outlined,
    _ => Icons.widgets_outlined,
  };
}
