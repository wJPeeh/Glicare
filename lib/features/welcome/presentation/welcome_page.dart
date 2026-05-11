import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/widgets/glicare_logo.dart';
import '../../../core/widgets/gradient_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -80,
            child: _AmbientGlow(
              color: AppColors.secondary.withValues(alpha: 0.18),
              size: 320,
            ),
          ),
          Positioned(
            bottom: -60,
            right: -40,
            child: _AmbientGlow(
              color: AppColors.primaryContainer.withValues(alpha: 0.14),
              size: 240,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.32,
            right: -80,
            child: Opacity(
              opacity: 0.07,
              child: Icon(
                Icons.show_chart,
                size: 360,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                    children: [
                      const SizedBox(height: 48),
                      const GlicareLogo(size: 80),
                      const SizedBox(height: 24),
                      Text(
                        'Glicare',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(height: 64),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Bem-vinda, Lilian!',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 280),
                          child: Text(
                            'Vamos cuidar da sua saúde hoje ❤️',
                            style: GoogleFonts.manrope(
                              fontSize: 17,
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      GradientButton(
                        label: 'Entrar',
                        icon: Icons.arrow_forward,
                        gradient: const LinearGradient(
                          colors: [Colors.white, Colors.white],
                        ),
                        foreground: AppColors.primary,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            offset: const Offset(0, 12),
                            blurRadius: 24,
                          ),
                        ],
                        onPressed: () => context.go(AppRoutes.login),
                      ),
                      const SizedBox(height: 16),
                      GlassButton(
                        label: 'Criar nova conta',
                        onPressed: () => context.go(AppRoutes.signup),
                      ),
                      const SizedBox(height: 56),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OU',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () => context.go(AppRoutes.susIntegration),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0078D7),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'SUS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Fazer login com SUS',
                                style: GoogleFonts.manrope(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 240),
                        child: Text(
                          'Ao continuar, você concorda com nossos termos de privacidade e uso de dados de saúde.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.45),
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.color, required this.size});
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
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
