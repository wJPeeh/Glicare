import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/config/feature_flags.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glicare_app_bar.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../auth/presentation/auth_controller.dart';

enum _PendingAuth { none, email, google, facebook, reset }

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  _PendingAuth _pending = _PendingAuth.none;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _run(
    _PendingAuth action,
    Future<bool> Function() task, {
    VoidCallback? onSuccess,
  }) async {
    setState(() => _pending = action);
    final ok = await task();
    if (!mounted) return;
    setState(() => _pending = _PendingAuth.none);
    if (ok && onSuccess != null) onSuccess();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await _run(
      _PendingAuth.email,
      () => ref.read(authControllerProvider.notifier).signInWithEmail(
            email: _emailController.text,
            password: _passwordController.text,
          ),
      onSuccess: () => context.go(AppRoutes.dashboard),
    );
  }

  Future<void> _signInWithGoogle() async {
    await _run(
      _PendingAuth.google,
      () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
      onSuccess: () => context.go(AppRoutes.dashboard),
    );
  }

  Future<void> _signInWithFacebook() async {
    await _run(
      _PendingAuth.facebook,
      () => ref.read(authControllerProvider.notifier).signInWithFacebook(),
      onSuccess: () => context.go(AppRoutes.dashboard),
    );
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe seu e-mail para receber o link.'),
        ),
      );
      return;
    }
    await _run(
      _PendingAuth.reset,
      () => ref.read(authControllerProvider.notifier).sendPasswordResetEmail(email),
      onSuccess: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Link de redefinição enviado para $email.')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = _pending != _PendingAuth.none;

    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(describeAuthError(error)),
                backgroundColor: AppColors.error,
              ),
            );
        },
      );
    });

    return Scaffold(
      appBar: GlicareAppBar(
        title: 'Glicare',
        action: const SizedBox(width: 40),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.health_and_safety,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Bem-vindo',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Acesse sua conta para monitorar sua saúde com precisão.',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),
              _Field(
                label: 'E-mail',
                hint: 'nome@exemplo.com',
                icon: Icons.mail_outline,
                controller: _emailController,
                enabled: !busy,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Informe seu e-mail.';
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
                    return 'E-mail inválido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _Field(
                label: 'Senha',
                hint: '••••••••',
                icon: Icons.lock_outline,
                controller: _passwordController,
                enabled: !busy,
                obscure: _obscure,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _submit(),
                suffix: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: busy
                      ? null
                      : () => setState(() => _obscure = !_obscure),
                  color: AppColors.outline,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe sua senha.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: busy ? null : _forgotPassword,
                  child: _pending == _PendingAuth.reset
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Esqueci minha senha',
                          style: GoogleFonts.manrope(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                label: _pending == _PendingAuth.email ? 'Entrando...' : 'Entrar',
                onPressed: busy ? null : _submit,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OU ACESSE COM',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: AppColors.outlineVariant,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SocialButton(
                      icon: Icons.g_mobiledata,
                      label: 'Google',
                      color: const Color(0xFFEA4335),
                      loading: _pending == _PendingAuth.google,
                      onTap: busy ? null : _signInWithGoogle,
                    ),
                  ),
                  if (kFacebookLoginEnabled) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SocialButton(
                        icon: Icons.facebook,
                        label: 'Facebook',
                        color: const Color(0xFF1877F2),
                        loading: _pending == _PendingAuth.facebook,
                        onTap: busy ? null : _signInWithFacebook,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.onSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: busy
                      ? null
                      : () => context.go(AppRoutes.susIntegration),
                  icon: const Icon(Icons.account_balance, size: 20),
                  label: Text(
                    'Acessar via SUS (Gov.br)',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    'Não possui conta? ',
                    style: GoogleFonts.manrope(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  GestureDetector(
                    onTap: busy ? null : () => context.go(AppRoutes.signup),
                    child: Text(
                      'Crie uma agora',
                      style: GoogleFonts.manrope(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _PrivacyCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.enabled = true,
    this.obscure = false,
    this.suffix,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool enabled;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          enabled: enabled,
          obscureText: obscure,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          onFieldSubmitted: onSubmitted,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            hintText: hint,
            hintStyle: GoogleFonts.manrope(
              color: AppColors.outline.withValues(alpha: 0.6),
            ),
            prefixIcon: Icon(icon, color: AppColors.outline),
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.loading = false,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: loading ? null : onTap,
          child: Center(
            child: loading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: color, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow(),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacidade Glicare',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Seus dados de saúde são criptografados e protegidos com os mais altos padrões de segurança.',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
