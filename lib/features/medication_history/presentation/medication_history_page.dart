import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bottom_nav.dart';

class MedicationHistoryPage extends StatelessWidget {
  const MedicationHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const GlicareBottomNav(activeIndex: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
                      backgroundColor: AppColors.surfaceContainerHighest,
                      child: Icon(Icons.person, color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Glicare',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.notifications_outlined, color: AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Histórico de Remédios',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Acompanhe seu plano de tratamento e adesão diária.',
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
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(child: _Tab(label: 'Hoje', selected: true)),
                    Expanded(child: _Tab(label: 'Anteriores', selected: false)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _TimelineEntry(
                statusIcon: Icons.check_circle,
                statusColor: AppColors.secondary,
                statusBg: AppColors.secondaryContainer,
                statusLabel: 'REALIZADO • 08:00',
                badge: _StatusBadge('TOMADO', AppColors.secondary, AppColors.secondary.withValues(alpha: 0.1)),
                title: 'Metformina',
                sub: '850mg • Comprimido',
                detail: 'Ingerido com café da manhã conforme prescrito.',
              ),
              const SizedBox(height: 24),
              _TimelineEntry(
                statusIcon: Icons.schedule,
                statusColor: AppColors.tertiaryFixedDim,
                statusBg: AppColors.tertiaryContainer.withValues(alpha: 0.2),
                statusLabel: 'PENDENTE • 13:00',
                badge: _StatusBadge('PENDENTE', AppColors.tertiary, AppColors.tertiaryContainer.withValues(alpha: 0.2)),
                title: 'Glifage XR',
                sub: '500mg • Comprimido',
                actions: [
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {},
                      child: const Text('Confirmar Dose', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.more_horiz, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _ScheduledEntry(),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: _AdherenceCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _StockCard()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.selected});
  final String label;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: selected ? AppColors.surfaceContainerLowest : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.label, this.fg, this.bg);
  final String label;
  final Color fg;
  final Color bg;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 10,
          color: fg,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.statusIcon,
    required this.statusColor,
    required this.statusBg,
    required this.statusLabel,
    required this.badge,
    required this.title,
    required this.sub,
    this.detail,
    this.actions,
  });
  final IconData statusIcon;
  final Color statusColor;
  final Color statusBg;
  final String statusLabel;
  final Widget badge;
  final String title;
  final String sub;
  final String? detail;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusBg,
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor),
            ),
            const SizedBox(width: 12),
            Text(
              statusLabel,
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppColors.softShadow(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            sub,
                            style: GoogleFonts.manrope(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    badge,
                  ],
                ),
                if (detail != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          detail!,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (actions != null) ...[
                  const SizedBox(height: 20),
                  Row(children: actions!),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ScheduledEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medication, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            Text(
              'PRÓXIMO • 20:00',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
                style: BorderStyle.solid,
              ),
            ),
            child: Opacity(
              opacity: 0.6,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sinvastatina',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text('20mg • Comprimido', style: GoogleFonts.manrope(color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  _StatusBadge('AGENDADO', AppColors.onSurfaceVariant, AppColors.surfaceContainerHighest),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdherenceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'ADESÃO\nSEMANAL',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              letterSpacing: 1.6,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '94%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: -2,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '+2%',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          Text(
            'Você manteve uma excelente consistência esta semana.',
            style: GoogleFonts.manrope(
              fontSize: 11,
              color: AppColors.onPrimaryContainer,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StockCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'ESTOQUE',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.6,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Metformina',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                  Text(
                    '5 dias',
                    style: GoogleFonts.manrope(
                      color: AppColors.error,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: 0.2,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.5),
                  valueColor: const AlwaysStoppedAnimation(AppColors.error),
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'RENOVAR RECEITA',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 1.4,
                ),
              ),
              const Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }
}
