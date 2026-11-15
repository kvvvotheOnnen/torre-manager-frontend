import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'design_tokens.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(lightPalette);

  static ThemeData dark() => _build(darkPalette);

  static ThemeData _build(AppPalette p) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: p.primary,
      brightness: p.brightness,
    ).copyWith(
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: p.primaryDeep,
      onPrimaryContainer: p.onPrimary,
      secondary: p.accent,
      onSecondary: p.onAccent,
      secondaryContainer: p.accent.withValues(alpha: p.isDark ? 0.18 : 0.22),
      onSecondaryContainer: p.ink,
      surface: p.surface,
      onSurface: p.ink,
      surfaceContainerLowest: p.surface,
      surfaceContainerLow: p.surfaceAlt,
      surfaceContainer: p.surfaceAlt,
      surfaceContainerHigh: p.surfaceStrong,
      surfaceContainerHighest: p.surfaceStrong,
      onSurfaceVariant: p.inkMuted,
      error: p.danger,
      onError: Colors.white,
      outline: p.border,
      outlineVariant: p.border.withValues(alpha: 0.6),
      shadow: p.isDark ? Colors.black : const Color(0xFF0B1220),
    );

    final textTheme = AppTypography.textTheme(p.brightness, p.ink, p.inkMuted);
    final isWebOrDesktop = _isWebOrDesktop();

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      textTheme: textTheme,
      dividerColor: p.border,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final platform in TargetPlatform.values)
            platform: isWebOrDesktop
                ? const _NoTransitionsBuilder()
                : const FadeForwardsPageTransitionsBuilder(),
        },
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: const WidgetStatePropertyAll(true),
        thickness: const WidgetStatePropertyAll(8),
        radius: const Radius.circular(999),
        thumbColor: WidgetStatePropertyAll(p.inkMuted.withValues(alpha: 0.35)),
        crossAxisMargin: 4,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.accent,
        selectionColor: p.primary.withValues(alpha: 0.24),
        selectionHandleColor: p.primary,
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: p.background,
        foregroundColor: p.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: colorScheme.shadow,
        elevation: p.isDark ? 0 : 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.lgAll,
          side: BorderSide(color: p.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.xlAll),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: p.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: p.inkMuted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: p.inkMuted),
        floatingLabelStyle: textTheme.labelMedium?.copyWith(color: p.primary),
        prefixIconColor: p.inkMuted,
        suffixIconColor: p.inkMuted,
        border: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: p.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: p.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: p.danger, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.ink,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          textStyle: textTheme.labelLarge,
          side: BorderSide(color: p.border),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.smAll),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: p.ink,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.smAll),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surfaceAlt,
        side: BorderSide(color: p.border),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.smAll),
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.isDark ? p.surfaceStrong : p.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: p.isDark ? p.ink : Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.smAll),
        actionTextColor: p.accent,
      ),
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.isDark ? p.surfaceStrong : p.ink,
          borderRadius: AppRadii.smAll,
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: p.isDark ? p.ink : Colors.white,
        ),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.primary.withValues(alpha: 0.12),
      ),
    );
  }

  static bool _isWebOrDesktop() {
    if (kIsWeb) return true;
    return switch (defaultTargetPlatform) {
      TargetPlatform.linux ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => true,
      _ => false,
    };
  }
}

class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
