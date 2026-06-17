import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../medication/presentation/medication_log_providers.dart';
import '../../profile/presentation/profile_providers.dart';

class NotificationsOnboardingPage extends ConsumerStatefulWidget {
  const NotificationsOnboardingPage({super.key});

  @override
  ConsumerState<NotificationsOnboardingPage> createState() =>
      _NotificationsOnboardingPageState();
}

class _NotificationsOnboardingPageState
    extends ConsumerState<NotificationsOnboardingPage> {
  bool _busy = false;

  Future<void> _finish({required bool granted}) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _busy = true);
    try {
      if (granted) {
        await ref.read(medicationNotificationsProvider).requestPermissions();
      }
      await ref
          .read(userProfileRepositoryProvider)
          .setNotificationsOnboarded(uid: user.uid, value: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao concluir: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(
                        Icons.notifications_active,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Não perca um\nhorário sequer',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.2,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'O Glicare envia lembretes na hora de cada dose das suas medicações, mesmo com o app fechado.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _BenefitRow(
                    icon: Icons.medication,
                    title: 'Lembretes de medicação',
                    body: 'No horário exato que você cadastrou.',
                  ),
                  const SizedBox(height: 12),
                  _BenefitRow(
                    icon: Icons.inventory_2_outlined,
                    title: 'Avisos de estoque',
                    body: 'Quando seus comprimidos estiverem acabando.',
                  ),
                  const SizedBox(height: 12),
                  _BenefitRow(
                    icon: Icons.insights,
                    title: 'Alertas inteligentes',
                    body: 'Quando algo no seu padrão precisa de atenção.',
                  ),
                  const Spacer(),
                  GradientButton(
                    label: _busy ? 'Aguarde...' : 'Permitir notificações',
                    icon: Icons.check_circle,
                    gradient: const LinearGradient(
                      colors: [Colors.white, Colors.white],
                    ),
                    foreground: AppColors.primary,
                    onPressed: _busy ? null : () => _finish(granted: true),
                  ),
                  const SizedBox(height: 12),
                  GlassButton(
                    label: 'Agora não',
                    onPressed: _busy ? null : () => _finish(granted: false),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Você pode mudar isso depois em Configurações do telefone.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  body,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.75),
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
