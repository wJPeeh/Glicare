import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bottom_nav.dart';

class SmartAlertsPage extends StatelessWidget {
  const SmartAlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const GlicareBottomNav(activeIndex: 3),
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
                      radius: 16,
                      backgroundColor: AppColors.surfaceContainer,
                      child: Icon(Icons.person, color: AppColors.onSurfaceVariant, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Glicare',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
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
                'Alertas Inteligentes',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Insights personalizados baseados no seu comportamento recente.',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              _AlertCard(
                accent: AppColors.tertiary,
                badge: AppColors.tertiaryContainer,
                badgeFg: AppColors.onTertiaryContainer,
                icon: Icons.warning,
                title: 'Atenção: Risco de Hiperglicemia',
                meta: 'DETECTADO HÁ 15 MIN',
                body: 'Sua curva glicêmica apresenta tendência de alta após o almoço. Pode ultrapassar 180 mg/dL na próxima hora.',
                recommendations: const [
                  ('Beba 300ml de água agora.', Icons.water_drop),
                  ('Considere uma caminhada leve de 10 min.', Icons.directions_walk),
                ],
                primaryLabel: 'Registrar Insulina',
                primaryColor: AppColors.tertiaryFixedDim,
                secondaryLabel: 'Ignorar',
              ),
              const SizedBox(height: 16),
              _AlertCard(
                accent: AppColors.primary,
                badge: AppColors.primaryContainer.withValues(alpha: 0.4),
                badgeFg: AppColors.primary,
                icon: Icons.medication,
                title: 'Lembrete: Hora da Medicação',
                meta: 'PROGRAMADO PARA 18:00',
                body: 'Está na hora da sua dose de Metformina (850mg). Manter a regularidade é essencial para sua hemoglobina glicada.',
                infoRow: const [
                  ('Última dose registrada', 'Ontem, 18:05'),
                  ('Estoque', '12 dias restantes'),
                ],
                primaryLabel: 'Confirmar Ingestão',
                primaryColor: AppColors.primary,
              ),
              const SizedBox(height: 16),
              _AlertCard(
                accent: AppColors.secondary,
                badge: AppColors.secondaryContainer,
                badgeFg: AppColors.onSecondaryContainer,
                icon: Icons.workspace_premium,
                title: 'Parabéns! Meta Diária Atingida!',
                meta: 'CONQUISTA DE HOJE',
                body: 'Você manteve seus níveis dentro do alvo por 92% do dia. Sua disciplina hoje foi exemplar.',
                statsGrid: const [
                  ('TEMPO NO ALVO', '22h 05m'),
                  ('VARIABILIDADE', 'Baixa'),
                ],
                shareLabel: 'Compartilhar Progresso',
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.query_stats, color: AppColors.outlineVariant),
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                        children: const [
                          TextSpan(text: 'Nossos algoritmos analisam mais de '),
                          TextSpan(
                            text: '50 pontos de dados',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
                          ),
                          TextSpan(text: ' diários para gerar esses alertas.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.accent,
    required this.badge,
    required this.badgeFg,
    required this.icon,
    required this.title,
    required this.meta,
    required this.body,
    this.recommendations,
    this.infoRow,
    this.statsGrid,
    this.primaryLabel,
    this.primaryColor,
    this.secondaryLabel,
    this.shareLabel,
  });

  final Color accent;
  final Color badge;
  final Color badgeFg;
  final IconData icon;
  final String title;
  final String meta;
  final String body;
  final List<(String, IconData)>? recommendations;
  final List<(String, String)>? infoRow;
  final List<(String, String)>? statsGrid;
  final String? primaryLabel;
  final Color? primaryColor;
  final String? secondaryLabel;
  final String? shareLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(36),
        boxShadow: AppColors.softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: badge,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: badgeFg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meta,
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                        letterSpacing: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            body,
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          if (recommendations != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RECOMENDAÇÕES GLICARE',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...recommendations!.map((r) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(r.$2, color: accent, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                r.$1,
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
          if (infoRow != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < infoRow!.length; i++) ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            infoRow![i].$1,
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            infoRow![i].$2,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < infoRow!.length - 1)
                      Container(
                        width: 1,
                        height: 32,
                        color: AppColors.outlineVariant.withValues(alpha: 0.3),
                      ),
                  ],
                ],
              ),
            ),
          ],
          if (statsGrid != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                for (var i = 0; i < statsGrid!.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            statsGrid![i].$1,
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurfaceVariant,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            statsGrid![i].$2,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.secondary,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (shareLabel != null) ...[
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.share, color: accent, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    shareLabel!,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (primaryLabel != null) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryColor ?? AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                      ),
                      onPressed: () {},
                      child: Text(primaryLabel!,
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
                if (secondaryLabel != null) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.4), width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                        foregroundColor: AppColors.onSurfaceVariant,
                      ),
                      onPressed: () {},
                      child: Text(secondaryLabel!, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
