import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Padding inferior que respeta la barra de navegación del sistema.
EdgeInsets appScrollPadding(BuildContext context, {EdgeInsetsGeometry? padding}) {
  final base = padding ?? const EdgeInsets.all(AppSpacing.xl);
  final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
  final resolved = base.resolve(Directionality.of(context));
  return resolved.copyWith(bottom: resolved.bottom + bottomInset + AppSpacing.lg);
}

/// Lista vertical con scrollbar, cierre de teclado al arrastrar y espacio
/// inferior dinámico para la barra de navegación del sistema.
class AppScrollView extends StatelessWidget {
  const AppScrollView({
    super.key,
    required this.children,
    this.padding,
    this.controller,
    this.physics,
    this.shrinkWrap = false,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      child: ListView(
        controller: controller,
        physics: physics,
        shrinkWrap: shrinkWrap,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: appScrollPadding(context, padding: padding),
        children: children,
      ),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (details.direction == AxisDirection.left ||
        details.direction == AxisDirection.right) {
      return child;
    }
    return Scrollbar(controller: details.controller, child: child);
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}
