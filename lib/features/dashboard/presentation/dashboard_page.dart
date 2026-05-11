import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_providers.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: GlicareBottomNav(
        activeIndex: 0,
        onTap: (i) {
          switch (i) {
            case 1: context.go(AppRoutes.evolutionCharts); break;
            case 3: context.go(AppRoutes.smartAlerts); break;
            case 4: context.go(AppRoutes.susIntegration); break;
          }
        },
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _DashboardHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const _GlucoseCard(),
                  const SizedBox(height: 32),
                  const _AiPredictionSection(),
                  const SizedBox(height: 32),
                  const _QuickActionsSection(),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final displayName = _resolveName(user?.displayName, user?.email);
    final photoUrl = user?.photoURL;

    Future<void> handleLogout() async {
      await ref.read(authControllerProvider.notifier).signOut();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(2),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainerHighest,
                border: Border.all(color: Colors.white, width: 2),
                image: photoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(photoUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: photoUrl == null
                  ? const Icon(Icons.person, color: AppColors.onSurfaceVariant)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OLÁ,',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  displayName,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            tooltip: 'Conta',
            position: PopupMenuPosition.under,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) {
              if (value == 'logout') handleLogout();
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.error, size: 20),
                    SizedBox(width: 12),
                    Text('Sair'),
                  ],
                ),
              ),
            ],
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.more_vert, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  String _resolveName(String? displayName, String? email) {
    final trimmed = displayName?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed.split(' ').first;
    }
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return 'Usuária';
  }
}

class _GlucoseCard extends StatelessWidget {
  const _GlucoseCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            offset: const Offset(0, 20),
            blurRadius: 48,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GLICEMIA ATUAL',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                        letterSpacing: 2.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '112',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 64,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            letterSpacing: -3,
                            height: 0.95,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'mg/dL',
                            style: GoogleFonts.manrope(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.secondaryContainer),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'NORMAL',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.onSecondaryContainer,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.schedule, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '08:15',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      'ÚLTIMA MEDIDA: JEJUM',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiPredictionSection extends StatelessWidget {
  const _AiPredictionSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IA Ativa',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'Previsão baseada no seu histórico',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            boxShadow: AppColors.softShadow(),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 140,
                child: CustomPaint(
                  painter: _AiCurvePainter(),
                  child: Row(
                    children: [
                      _DataPoint(value: '116', label: 'AGORA'),
                      _DataPoint(value: '125', label: '10H', highlighted: true),
                      _DataPoint(value: '110', label: '12H'),
                      _DataPoint(value: '105', label: '14H'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerLow,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => GoRouter.of(context).go(AppRoutes.evolutionCharts),
                  icon: Text(
                    'Ver histórico completo',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  label: const Icon(Icons.arrow_forward, size: 18, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DataPoint extends StatelessWidget {
  const _DataPoint({required this.value, required this.label, this.highlighted = false});
  final String value;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? AppColors.primary : AppColors.outline.withValues(alpha: 0.6);
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: highlighted ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: highlighted ? 16 : 12,
            height: highlighted ? 16 : 12,
            decoration: BoxDecoration(
              color: highlighted ? AppColors.primary : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: highlighted ? Colors.white : AppColors.primary.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: highlighted
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                      )
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primary, AppColors.secondary],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final w = size.width;
    final h = size.height * 0.6;
    path.moveTo(w * 0.125, h * 0.65);
    path.cubicTo(w * 0.25, h * 0.55, w * 0.25, h * 0.35, w * 0.375, h * 0.45);
    path.cubicTo(w * 0.5, h * 0.55, w * 0.5, h * 0.65, w * 0.625, h * 0.65);
    path.cubicTo(w * 0.75, h * 0.65, w * 0.75, h * 0.75, w * 0.875, h * 0.75);

    canvas.drawPath(path, paint..color = AppColors.primary.withValues(alpha: 0.4));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações rápidas',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.05,
          children: [
            _ActionCard(
              icon: Icons.bloodtype,
              title: 'Registrar\nGlicemia',
              tint: AppColors.primary,
              onTap: () {},
            ),
            _ActionCard(
              icon: Icons.restaurant,
              title: 'Adicionar\nRefeição',
              tint: AppColors.secondary,
              onTap: () => GoRouter.of(context).go(AppRoutes.mealLog),
            ),
            _ActionCard(
              icon: Icons.fitness_center,
              title: 'Registrar\nAtividade',
              tint: AppColors.tertiaryFixedDim,
              onTap: () {},
            ),
            _ActionCard(
              icon: Icons.medication,
              title: 'Tomar\nMedicação',
              tint: AppColors.error,
              onTap: () => GoRouter.of(context).go(AppRoutes.medicationRegister),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.tint,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final Color tint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(36),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(36),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            boxShadow: AppColors.softShadow(y: 8, blur: 24, opacity: 0.04),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: tint, size: 26),
              ),
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
