import 'package:flutter/material.dart';

/// Vista amigable cuando un widget falla al construirse (release).
class AppErrorView extends StatelessWidget {
  const AppErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
    final background = isDark ? const Color(0xFF070B14) : const Color(0xFFF4F6FB);
    final ink = isDark ? const Color(0xFFF3F6FC) : const Color(0xFF0B1220);
    final muted = isDark ? const Color(0xFF9AA7BE) : const Color(0xFF55627A);
    final accent = isDark ? const Color(0xFFFFC65C) : const Color(0xFFF5B544);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: background,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.architecture_rounded, size: 44, color: accent),
                const SizedBox(height: 14),
                Text(
                  'Algo salió mal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Estamos trabajando para mostrarte esta sección.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
