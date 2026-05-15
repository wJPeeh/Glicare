import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../analytics/data/glucose_analytics.dart';
import '../../analytics/presentation/analytics_providers.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../glucose_log/data/glucose_reading.dart';
import '../../glucose_log/presentation/glucose_providers.dart';

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
            case 2: showRegisterActionSheet(context); break;
            case 3: context.go(AppRoutes.smartAlerts); break;
            case 4: context.go(AppRoutes.profile); break;
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

    void openProfile() => context.push(AppRoutes.profile);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: openProfile,
            behavior: HitTestBehavior.opaque,
            child: Container(
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
              switch (value) {
                case 'profile':
                  openProfile();
                  break;
                case 'logout':
                  handleLogout();
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: AppColors.primary, size: 20),
                    SizedBox(width: 12),
                    Text('Perfil'),
                  ],
                ),
              ),
              PopupMenuDivider(),
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

class _GlucoseCard extends ConsumerWidget {
  const _GlucoseCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readings = ref.watch(recentGlucoseReadingsProvider);
    return readings.when(
      loading: () => const _GlucoseCardShell(child: _GlucoseLoading()),
      error: (_, __) =>
          const _GlucoseCardShell(child: _GlucoseEmpty(error: true)),
      data: (list) {
        if (list.isEmpty) {
          return const _GlucoseCardShell(child: _GlucoseEmpty());
        }
        return _GlucoseCardShell(child: _GlucoseFilled(latest: list.first));
      },
    );
  }
}

class _GlucoseCardShell extends StatelessWidget {
  const _GlucoseCardShell({required this.child});
  final Widget child;

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
      child: child,
    );
  }
}

class _GlucoseLoading extends StatelessWidget {
  const _GlucoseLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 140,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _GlucoseEmpty extends StatelessWidget {
  const _GlucoseEmpty({this.error = false});
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.bloodtype, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    error
                        ? 'Falha ao carregar suas medições'
                        : 'Nenhuma medição registrada',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    error
                        ? 'Verifique sua conexão e tente novamente.'
                        : 'Toque em "Registrar Glicemia" abaixo para começar.',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GlucoseFilled extends StatelessWidget {
  const _GlucoseFilled({required this.latest});
  final GlucoseReading latest;

  @override
  Widget build(BuildContext context) {
    final range = rangeFor(latest.valueMgdl);
    final (badgeBg, badgeFg, dotColor) = switch (range) {
      GlucoseRange.hipo => (
          AppColors.error.withValues(alpha: 0.12),
          AppColors.error,
          AppColors.error,
        ),
      GlucoseRange.normal => (
          AppColors.secondaryContainer.withValues(alpha: 0.5),
          AppColors.onSecondaryContainer,
          AppColors.secondary,
        ),
      GlucoseRange.elevada => (
          AppColors.tertiaryContainer.withValues(alpha: 0.4),
          AppColors.tertiary,
          AppColors.tertiaryFixedDim,
        ),
      GlucoseRange.hiper => (
          AppColors.error.withValues(alpha: 0.12),
          AppColors.error,
          AppColors.error,
        ),
    };
    final valueColor = range == GlucoseRange.normal
        ? AppColors.primary
        : (range == GlucoseRange.elevada
            ? AppColors.tertiaryFixedDim
            : AppColors.error);
    final timeFormatter = DateFormat('HH:mm');
    final dateFormatter = DateFormat('dd/MM');
    final now = DateTime.now();
    final measured = latest.measuredAt;
    final sameDay = now.year == measured.year &&
        now.month == measured.month &&
        now.day == measured.day;
    final timeLabel = sameDay
        ? timeFormatter.format(measured)
        : '${dateFormatter.format(measured)} • ${timeFormatter.format(measured)}';
    final subLabel = (latest.notes != null && latest.notes!.trim().isNotEmpty)
        ? latest.notes!.trim().toUpperCase()
        : (sameDay ? 'ÚLTIMA MEDIÇÃO HOJE' : 'ÚLTIMA MEDIÇÃO');

    return Column(
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
                        '${latest.valueMgdl}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          color: valueColor,
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
                            color:
                                AppColors.onSurfaceVariant.withValues(alpha: 0.6),
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
                color: badgeBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration:
                        BoxDecoration(color: dotColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    range.label,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: badgeFg,
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
                child:
                    const Icon(Icons.schedule, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeLabel,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      subLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AiPredictionSection extends ConsumerWidget {
  const _AiPredictionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readings = ref.watch(recentGlucoseReadingsProvider);
    final stats = ref.watch(dashboardGlucoseStatsProvider);
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
                    'Análise das suas últimas medições',
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
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.primary,
                size: 18,
              ),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 140,
                child: readings.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(
                    child: Text(
                      'Falha ao carregar histórico.',
                      style: GoogleFonts.manrope(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  data: (list) => _AiPoints(readings: list),
                ),
              ),
              const SizedBox(height: 16),
              stats.maybeWhen(
                data: (s) => _InsightBanner(stats: s),
                orElse: () => const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerLow,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () =>
                      GoRouter.of(context).go(AppRoutes.evolutionCharts),
                  icon: Text(
                    'Ver histórico completo',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  label: const Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AiPoints extends StatelessWidget {
  const _AiPoints({required this.readings});
  final List<GlucoseReading> readings;

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Registre suas primeiras medições para ver tendências aqui.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      );
    }
    final latest = readings.take(4).toList().reversed.toList();
    final maxValue = latest.map((r) => r.valueMgdl).reduce(math.max);
    final timeFormatter = DateFormat('HH:mm');
    return CustomPaint(
      painter: _AiCurvePainter(
        values: latest.map((r) => r.valueMgdl.toDouble()).toList(),
      ),
      child: Row(
        children: [
          for (var i = 0; i < latest.length; i++)
            _DataPoint(
              value: '${latest[i].valueMgdl}',
              label: i == latest.length - 1
                  ? 'AGORA'
                  : timeFormatter.format(latest[i].measuredAt).toUpperCase(),
              highlighted: i == latest.length - 1,
              maxValue: maxValue,
            ),
        ],
      ),
    );
  }
}

class _InsightBanner extends StatelessWidget {
  const _InsightBanner({required this.stats});
  final GlucoseStats stats;

  @override
  Widget build(BuildContext context) {
    final headline = buildHeadline(stats);
    final secondary = buildSecondaryInsight(stats);
    final accent = switch (stats.trend) {
      TrendDirection.melhorando => AppColors.secondary,
      TrendDirection.piorando => AppColors.error,
      TrendDirection.estavel => AppColors.primary,
      TrendDirection.semDados => AppColors.outline,
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.insights, color: accent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    height: 1.3,
                  ),
                ),
                if (secondary != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    secondary,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DataPoint extends StatelessWidget {
  const _DataPoint({
    required this.value,
    required this.label,
    this.highlighted = false,
    this.maxValue = 200,
  });
  final String value;
  final String label;
  final bool highlighted;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    final color = highlighted
        ? AppColors.primary
        : AppColors.outline.withValues(alpha: 0.6);
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color:
                  highlighted ? AppColors.primary : AppColors.onSurfaceVariant,
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
                color: highlighted
                    ? Colors.white
                    : AppColors.primary.withValues(alpha: 0.4),
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
  _AiCurvePainter({this.values = const []});
  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final w = size.width;
    final h = size.height;
    final maxV = values.reduce(math.max);
    final minV = values.reduce(math.min);
    final span = (maxV - minV).abs() < 1 ? 1.0 : (maxV - minV);
    final topPad = h * 0.18;
    final bottomPad = h * 0.45;
    final usableH = h - topPad - bottomPad;
    final stepX = w / (values.length - 1);

    Offset pointFor(int i) {
      final norm = (values[i] - minV) / span;
      final y = topPad + (1 - norm) * usableH;
      return Offset(i * stepX, y);
    }

    final path = Path()..moveTo(pointFor(0).dx, pointFor(0).dy);
    for (var i = 1; i < values.length; i++) {
      final prev = pointFor(i - 1);
      final curr = pointFor(i);
      final cx = (prev.dx + curr.dx) / 2;
      path.cubicTo(cx, prev.dy, cx, curr.dy, curr.dx, curr.dy);
    }
    final stroke = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primary, AppColors.secondary],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _AiCurvePainter oldDelegate) =>
      oldDelegate.values != values;
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
              highlighted: true,
              onTap: () => GoRouter.of(context).go(AppRoutes.glucoseRegister),
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
              onTap: () => GoRouter.of(context).go(AppRoutes.activityRegister),
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
    this.highlighted = false,
  });
  final IconData icon;
  final String title;
  final Color tint;
  final VoidCallback? onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = highlighted ? tint : Colors.white;
    final iconBg = highlighted
        ? Colors.white.withValues(alpha: 0.2)
        : tint.withValues(alpha: 0.1);
    final iconColor = highlighted ? Colors.white : tint;
    final titleColor = highlighted ? Colors.white : AppColors.onSurface;
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(36),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(36),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(36),
            boxShadow: highlighted
                ? AppColors.primaryGlow(opacity: 0.25)
                : AppColors.softShadow(y: 8, blur: 24, opacity: 0.04),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
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
