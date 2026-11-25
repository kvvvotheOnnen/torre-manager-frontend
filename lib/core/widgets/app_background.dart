import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Fondo con gradiente arquitectónico, retícula sutil y halos de color.
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.showGlow = false,
    this.showPattern = false,
    this.dark = false,
  });

  final Widget child;
  final bool showGlow;
  final bool showPattern;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = dark || p.isDark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF060A12),
                  Color(0xFF0B1424),
                  Color(0xFF131F3A),
                ],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF7F9FE),
                  Color(0xFFEEF2FA),
                  Color(0xFFE6ECF8),
                ],
              ),
      ),
      child: Stack(
        children: [
          if (showPattern)
            Positioned.fill(
              child: CustomPaint(
                painter: _BlueprintPainter(
                  lineColor: (isDark ? Colors.white : const Color(0xFF0B1220))
                      .withValues(alpha: isDark ? 0.05 : 0.045),
                  step: 46,
                ),
              ),
            ),
          if (showGlow) ...[
            Positioned(
              top: -140,
              right: -100,
              child: _Glow(
                color: p.accent.withValues(alpha: isDark ? 0.24 : 0.26),
                size: 360,
              ),
            ),
            Positioned(
              bottom: -160,
              left: -120,
              child: _Glow(
                color: p.primary.withValues(alpha: isDark ? 0.32 : 0.22),
                size: 420,
              ),
            ),
          ],
          child,
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

class _BlueprintPainter extends CustomPainter {
  _BlueprintPainter({required this.lineColor, required this.step});

  final Color lineColor;
  final double step;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final accent = Paint()
      ..color = lineColor.withValues(alpha: math.min(1.0, lineColor.a * 2.4))
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(size.width * 0.72, 0),
      Offset(size.width * 0.72, size.height),
      accent,
    );
  }

  @override
  bool shouldRepaint(covariant _BlueprintPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor || oldDelegate.step != step;
  }
}
