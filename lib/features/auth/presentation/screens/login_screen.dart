import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/brand_mark.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/top_bar.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      return;
    }

    FocusScope.of(context).unfocus();
    HapticFeedback.selectionClick();
    context.read<AuthBloc>().add(
      LoginRequested(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        showPattern: true,
        showGlow: true,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 980;
              if (!isWide) {
                return _MobileLogin(
                  formKey: _formKey,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  obscurePassword: _obscurePassword,
                  onTogglePassword: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  onSubmit: _submit,
                );
              }

              return Row(
                children: [
                  const Expanded(flex: 6, child: _BrandPanel()),
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.xxl,
                          AppSpacing.xxl,
                          AppSpacing.xxl,
                          AppSpacing.xxl +
                              MediaQuery.viewPaddingOf(context).bottom,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 430),
                          child: _LoginCard(
                            formKey: _formKey,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            obscurePassword: _obscurePassword,
                            onTogglePassword: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            onSubmit: _submit,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final theme = Theme.of(context);
    final isDark = p.isDark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: BrandMark(
                  size: 48,
                  showWordmark: true,
                  subtitle: 'PREMIUM CONDOMINIUM OPS',
                ),
              ),
              ThemeToggleButton(),
            ],
          ),
          const Spacer(),
          Text(
            'La operación de tu\ncondominio, en una\nsola torre.',
            style: theme.textTheme.displayMedium?.copyWith(
              color: isDark ? Colors.white : p.ink,
              height: 1.02,
              letterSpacing: -1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Accesos, paquetería, reservas y gastos comunes en una '
            'plataforma multi-tenant pensada para administrar con claridad.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white70 : p.inkMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _FeaturePill(
                icon: Icons.security_rounded,
                label: 'Control de acceso',
              ),
              _FeaturePill(
                icon: Icons.inventory_2_rounded,
                label: 'Paquetería',
              ),
              _FeaturePill(
                icon: Icons.receipt_long_rounded,
                label: 'Gastos comunes',
              ),
              _FeaturePill(
                icon: Icons.event_available_rounded,
                label: 'Reservas',
              ),
            ],
          ),
          const Spacer(),
          _TowerArt(isDark: isDark),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'MULTI-TENANT  ·  ROLES  ·  TRAZABILIDAD',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark ? Colors.white54 : p.inkMuted,
              letterSpacing: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: p.surface.withValues(alpha: p.isDark ? 0.12 : 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.border.withValues(alpha: 0.8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: p.accent),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _TowerArt extends StatelessWidget {
  const _TowerArt({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final base = isDark ? Colors.white : p.primaryDeep;
    final heights = [64.0, 104.0, 148.0, 92.0, 120.0];

    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < heights.length; i++) ...[
            Expanded(
              child: Container(
                height: heights[i],
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      base.withValues(alpha: isDark ? 0.30 : 0.16),
                      base.withValues(alpha: isDark ? 0.06 : 0.04),
                    ],
                  ),
                  border: Border.all(
                    color: base.withValues(alpha: isDark ? 0.22 : 0.12),
                  ),
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == 2 ? p.accent : base.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (i < heights.length - 1) const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _MobileLogin extends StatelessWidget {
  const _MobileLogin({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: const [
                  Expanded(
                    child: BrandMark(
                      size: 42,
                      showWordmark: true,
                      subtitle: 'PREMIUM CONDOMINIUM OPS',
                    ),
                  ),
                  ThemeToggleButton(),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'La operación de tu condominio,\nen una sola torre.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Administra accesos, paquetería, reservas y gastos comunes '
                'desde un solo lugar.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: p.inkMuted),
              ),
              const SizedBox(height: AppSpacing.xl),
              _LoginCard(
                formKey: formKey,
                emailController: emailController,
                passwordController: passwordController,
                obscurePassword: obscurePassword,
                onTogglePassword: onTogglePassword,
                onSubmit: onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      glowColor: p.primary,
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            HapticFeedback.heavyImpact();
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: p.danger,
                ),
              );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Bienvenido de vuelta',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Ingresa para administrar tu recinto.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: p.inkMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    hintText: 'tu@correo.cl',
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) return 'Ingresa tu correo';
                    final isValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(email);
                    if (!isValid) return 'Correo inválido';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  enabled: !isLoading,
                  onFieldSubmitted: (_) => onSubmit(),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: onTogglePassword,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu contraseña';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  height: 54,
                  child: FilledButton(
                    onPressed: isLoading ? null : onSubmit,
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Ingresar'),
                              SizedBox(width: AppSpacing.sm),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 14,
                      color: p.inkMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Acceso seguro · Torre Manager',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: p.inkMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Aún no tienes cuenta?',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: p.inkMuted,
                      ),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => context.go(AppRoutes.registro),
                      child: const Text('Regístrate'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
