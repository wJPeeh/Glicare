import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glicare_app_bar.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../auth/presentation/auth_controller.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _accepted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aceite os termos para continuar.'),
        ),
      );
      return;
    }
    final ok = await ref
        .read(authControllerProvider.notifier)
        .signUpWithEmail(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
    if (!mounted) return;
    if (ok) context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

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
            children: [
              const SizedBox(height: 16),
              Text(
                'Criar Conta',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Junte-se ao santuário da sua saúde.',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppColors.softShadow(),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      margin: const EdgeInsets.only(bottom: 24),
                    ),
                    _SignupField(
                      label: 'Nome Completo',
                      hint: 'Como devemos te chamar?',
                      icon: Icons.person_outline,
                      controller: _nameController,
                      enabled: !isLoading,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.length < 2) return 'Informe seu nome.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _SignupField(
                      label: 'E-mail',
                      hint: 'seu@email.com',
                      icon: Icons.mail_outline,
                      controller: _emailController,
                      enabled: !isLoading,
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
                    const SizedBox(height: 16),
                    _SignupField(
                      label: 'Senha',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscure: true,
                      controller: _passwordController,
                      enabled: !isLoading,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Use ao menos 6 caracteres.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _SignupField(
                      label: 'Confirmar Senha',
                      hint: '••••••••',
                      icon: Icons.lock_reset_outlined,
                      obscure: true,
                      controller: _confirmController,
                      enabled: !isLoading,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'As senhas não conferem.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _accepted,
                          onChanged: isLoading
                              ? null
                              : (v) => setState(() => _accepted = v ?? false),
                          activeColor: AppColors.primary,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.manrope(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                                children: [
                                  const TextSpan(text: 'Aceito os '),
                                  TextSpan(
                                    text: 'termos de uso',
                                    style: GoogleFonts.manrope(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const TextSpan(text: ' e '),
                                  TextSpan(
                                    text: 'política de privacidade',
                                    style: GoogleFonts.manrope(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GradientButton(
                      label: isLoading ? 'Criando...' : 'Criar Conta',
                      onPressed: (isLoading || !_accepted) ? null : _submit,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Já tem uma conta?  ',
                    style: GoogleFonts.manrope(color: AppColors.onSurfaceVariant),
                  ),
                  GestureDetector(
                    onTap: isLoading ? null : () => context.go(AppRoutes.login),
                    child: Text(
                      'Entrar',
                      style: GoogleFonts.manrope(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignupField extends StatelessWidget {
  const _SignupField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.enabled = true,
    this.obscure = false,
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
              fontWeight: FontWeight.w700,
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
            fillColor: AppColors.surfaceContainerLow,
            hintText: hint,
            hintStyle: GoogleFonts.manrope(color: AppColors.outline),
            prefixIcon: Icon(icon, color: AppColors.outline),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
