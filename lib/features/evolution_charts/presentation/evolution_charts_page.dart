import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bottom_nav.dart';

class EvolutionChartsPage extends StatelessWidget {
  const EvolutionChartsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const GlicareBottomNav(activeIndex: 1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.surfaceContainer,
                      child: Icon(Icons.person, color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Glicare',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: -1,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.notifications_outlined, color: AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Gráfico de Evolução',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Acompanhe seu progresso nos últimos períodos.',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RangeChip(label: '7 dias', selected: false),
                    _RangeChip(label: '30 dias', selected: true),
                    _RangeChip(label: '90 dias', selected: false),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: AppColors.softShadow(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MÉDIA DO PERÍODO',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '118',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            height: 1,
                            letterSpacing: -2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'mg/dL',
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.trending_down, color: AppColors.onSecondaryContainer, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '-8% MELHORIA',
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
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: AppColors.softShadow(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Legend(label: 'GLICEMIA', color: AppColors.primary),
                        const SizedBox(width: 16),
                        _Legend(label: 'META', color: AppColors.surfaceContainerHigh),
                        const Spacer(),
                        const Icon(Icons.more_horiz, color: AppColors.onSurfaceVariant),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 180,
                      child: CustomPaint(
                        painter: _ChartPainter(),
                        size: Size.infinite,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: ['01 OUT', '08 OUT', '15 OUT', '22 OUT', 'HOJE']
                          .map((d) => Text(
                                d,
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.onSurfaceVariant,
                                  letterSpacing: 1.4,
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Tendência Geral',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: AppColors.softShadow(),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.auto_graph, color: AppColors.secondary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'MELHORANDO',
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.secondary,
                                  letterSpacing: 1.6,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Suas glicemias estão mais estáveis! A variabilidade diminuiu 12% em relação ao mês anterior.',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Chip(label: 'Estável', icon: Icons.check_circle, fg: AppColors.onSecondaryContainer, bg: AppColors.secondaryContainer),
                  _Chip(label: 'Atenção ao Sono', icon: Icons.warning, fg: Colors.white, bg: AppColors.tertiaryFixedDim),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({required this.label, required this.selected});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : null,
        borderRadius: BorderRadius.circular(99),
        boxShadow: selected ? AppColors.primaryGlow(opacity: 0.2) : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.w800,
          fontSize: 13,
          color: selected ? Colors.white : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon, required this.fg, required this.bg});
  final String label;
  final IconData icon;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: fg,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // grid lines
    final gridPaint = Paint()
      ..color = AppColors.surfaceContainerHighest
      ..strokeWidth = 1;
    for (int i = 1; i < 4; i++) {
      final y = h * i / 4;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // path
    final path = Path()
      ..moveTo(0, h * 0.8)
      ..quadraticBezierTo(w * 0.1, h * 0.7, w * 0.2, h * 0.75)
      ..quadraticBezierTo(w * 0.3, h * 0.6, w * 0.4, h * 0.55)
      ..quadraticBezierTo(w * 0.5, h * 0.55, w * 0.6, h * 0.65)
      ..quadraticBezierTo(w * 0.7, h * 0.45, w * 0.8, h * 0.45)
      ..quadraticBezierTo(w * 0.9, h * 0.5, w, h * 0.52);

    final fillPath = Path.from(path)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.primary.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // points
    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final pointStrokePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final points = [
      Offset(w * 0.2, h * 0.75),
      Offset(w * 0.4, h * 0.55),
      Offset(w * 0.6, h * 0.65),
      Offset(w * 0.8, h * 0.45),
    ];
    for (final p in points) {
      canvas.drawCircle(p, 5, pointPaint);
      canvas.drawCircle(p, 5, pointStrokePaint);
    }

    canvas.drawCircle(
      Offset(w, h * 0.52),
      5,
      Paint()..color = AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
