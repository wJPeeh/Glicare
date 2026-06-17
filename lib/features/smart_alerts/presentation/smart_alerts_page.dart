import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../analytics/data/glucose_analytics.dart';
import '../../analytics/presentation/analytics_providers.dart';
import '../../glucose_log/data/glucose_reading.dart';
import '../../glucose_log/presentation/glucose_providers.dart';
import '../../medication/data/medication_adherence.dart';
import '../../medication/data/medication_schedule.dart';
import '../../medication/presentation/medication_log_providers.dart';

class SmartAlertsPage extends ConsumerStatefulWidget {
  const SmartAlertsPage({super.key});

  @override
  ConsumerState<SmartAlertsPage> createState() => _SmartAlertsPageState();
}

class _SmartAlertsPageState extends ConsumerState<SmartAlertsPage> {
  final Set<String> _dismissed = <String>{};

  void _dismiss(String id) {
    setState(() => _dismissed.add(id));
  }

  @override
  Widget build(BuildContext context) {
    final readings =
        ref.watch(recentGlucoseReadingsProvider).asData?.value ??
            const <GlucoseReading>[];
    final stats = ref.watch(glucoseStatsProvider(7)).asData?.value ??
        GlucoseStats.empty;
    final doses = ref.watch(todaysDosesProvider).asData?.value ??
        const <ScheduledDose>[];
    final lowStock = ref.watch(lowestStockScheduleProvider).asData?.value;

    final alerts = _buildAlerts(
      readings: readings,
      stats: stats,
      doses: doses,
      lowStock: lowStock,
    );
    final visible = alerts.where((a) => !_dismissed.contains(a.id)).toList();

    return Scaffold(
      bottomNavigationBar: GlicareBottomNav(
        activeIndex: 3,
        onTap: (i) {
          switch (i) {
            case 0: context.go(AppRoutes.dashboard); break;
            case 1: context.go(AppRoutes.evolutionCharts); break;
            case 2: showRegisterActionSheet(context); break;
            case 4: context.go(AppRoutes.profile); break;
          }
        },
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
                      radius: 16,
                      backgroundColor: AppColors.surfaceContainer,
                      child: Icon(Icons.person,
                          color: AppColors.onSurfaceVariant, size: 18),
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
                    if (_dismissed.isNotEmpty)
                      TextButton.icon(
                        onPressed: () => setState(_dismissed.clear),
                        icon: const Icon(Icons.refresh,
                            color: AppColors.primary, size: 18),
                        label: Text(
                          'Restaurar',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else
                      const Icon(Icons.notifications_outlined,
                          color: AppColors.primary),
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
                visible.isEmpty
                    ? 'Nenhum alerta pendente. Bom trabalho!'
                    : 'Insights personalizados baseados no seu comportamento recente.',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              if (visible.isEmpty)
                _EmptyState()
              else
                for (final alert in visible) ...[
                  _AlertCard(data: alert),
                  const SizedBox(height: 16),
                ],
              const SizedBox(height: 8),
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
                    const Icon(Icons.query_stats,
                        color: AppColors.outlineVariant),
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
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800),
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

  /// Gera os alertas a partir dos dados reais do usuário (glicemia, medicação
  /// e estatísticas recentes). Retorna lista vazia quando está tudo em ordem.
  List<_AlertData> _buildAlerts({
    required List<GlucoseReading> readings,
    required GlucoseStats stats,
    required List<ScheduledDose> doses,
    required MedicationSchedule? lowStock,
  }) {
    final now = DateTime.now();
    final alerts = <_AlertData>[];

    // 1. Alerta baseado na última medição de glicemia.
    if (readings.isNotEmpty) {
      final latest = readings.first; // ordenadas desc por measuredAt
      final range = rangeFor(latest.valueMgdl);
      final ago = _formatAgo(latest.measuredAt, now);
      if (range == GlucoseRange.hiper) {
        alerts.add(_AlertData(
          id: 'hyperglycemia',
          accent: AppColors.tertiary,
          badge: AppColors.tertiaryContainer,
          badgeFg: AppColors.onTertiaryContainer,
          icon: Icons.warning,
          title: 'Atenção: Glicemia Alta',
          meta: 'ÚLTIMA MEDIÇÃO $ago • ${latest.valueMgdl} MG/DL',
          body:
              'Sua última medição (${latest.valueMgdl} mg/dL) está acima da faixa alvo (70–140). Pequenas ações agora ajudam a estabilizar.',
          recommendations: const [
            ('Beba 300ml de água agora.', Icons.water_drop),
            ('Considere uma caminhada leve de 10 min.', Icons.directions_walk),
          ],
          primaryLabel: 'Registrar Glicemia',
          primaryColor: AppColors.tertiaryFixedDim,
          onPrimary: () => context.push(AppRoutes.glucoseRegister),
          secondaryLabel: 'Ignorar',
          onSecondary: () => _dismiss('hyperglycemia'),
        ));
      } else if (range == GlucoseRange.hipo) {
        alerts.add(_AlertData(
          id: 'hypoglycemia',
          accent: AppColors.error,
          badge: AppColors.errorContainer,
          badgeFg: AppColors.onErrorContainer,
          icon: Icons.priority_high,
          title: 'Cuidado: Glicemia Baixa',
          meta: 'ÚLTIMA MEDIÇÃO $ago • ${latest.valueMgdl} MG/DL',
          body:
              'Sua última medição (${latest.valueMgdl} mg/dL) está abaixo de 70. Aja rápido para evitar uma hipoglicemia.',
          recommendations: const [
            ('Consuma 15g de carboidrato rápido (suco/balas).',
                Icons.local_drink),
            ('Refaça a medição em 15 minutos.', Icons.timer),
          ],
          primaryLabel: 'Registrar Glicemia',
          primaryColor: AppColors.error,
          onPrimary: () => context.push(AppRoutes.glucoseRegister),
          secondaryLabel: 'Ignorar',
          onSecondary: () => _dismiss('hypoglycemia'),
        ));
      }
    }

    // 2. Tendência de alta nas medições recentes.
    if (stats.count >= 3 && stats.trend == TrendDirection.piorando) {
      alerts.add(_AlertData(
        id: 'trend-up',
        accent: AppColors.tertiary,
        badge: AppColors.tertiaryContainer.withValues(alpha: 0.6),
        badgeFg: AppColors.onTertiaryContainer,
        icon: Icons.trending_up,
        title: 'Sua glicemia está em alta',
        meta: 'TENDÊNCIA DOS ÚLTIMOS 7 DIAS',
        body:
            'A média recente é de ${stats.average.round()} mg/dL e vem subindo. Vale revisar alimentação e adesão à medicação.',
        infoRow: [
          ('Média (7 dias)', '${stats.average.round()} mg/dL'),
          ('No alvo', '${stats.timeInRangePct.toStringAsFixed(0)}%'),
        ],
        primaryLabel: 'Ver Evolução',
        primaryColor: AppColors.tertiaryFixedDim,
        onPrimary: () => context.push(AppRoutes.evolutionCharts),
        secondaryLabel: 'Ignorar',
        onSecondary: () => _dismiss('trend-up'),
      ));
    }

    // 3. Dose de medicação atrasada ou pendente.
    final pendingDose = doses
        .where((d) =>
            d.status == DoseStatus.atrasado || d.status == DoseStatus.pendente)
        .fold<ScheduledDose?>(null, (earliest, d) {
      if (earliest == null) return d;
      return d.scheduledAt.isBefore(earliest.scheduledAt) ? d : earliest;
    });
    if (pendingDose != null) {
      final s = pendingDose.schedule;
      final late = pendingDose.status == DoseStatus.atrasado;
      final dosageText = s.dosage.trim().isNotEmpty ? ' (${s.dosage})' : '';
      alerts.add(_AlertData(
        id: 'medication-${s.id}-${pendingDose.expectedMinute}',
        accent: late ? AppColors.error : AppColors.primary,
        badge: late
            ? AppColors.errorContainer
            : AppColors.primaryContainer.withValues(alpha: 0.4),
        badgeFg: late ? AppColors.onErrorContainer : AppColors.primary,
        icon: Icons.medication,
        title: late ? 'Dose Atrasada' : 'Lembrete: Hora da Medicação',
        meta: 'PROGRAMADO PARA ${formatMinutes(pendingDose.expectedMinute)}',
        body:
            'Está na hora da sua dose de ${s.name}$dosageText. Manter a regularidade é essencial para o seu controle glicêmico.',
        infoRow: s.tracksStock && s.daysOfStockRemaining != null
            ? [
                ('Horário', formatMinutes(pendingDose.expectedMinute)),
                ('Estoque', '${s.daysOfStockRemaining} dias restantes'),
              ]
            : null,
        primaryLabel: 'Confirmar Ingestão',
        primaryColor: late ? AppColors.error : AppColors.primary,
        onPrimary: () => context.push(AppRoutes.medicationRegister),
        secondaryLabel: 'Ignorar',
        onSecondary: () =>
            _dismiss('medication-${s.id}-${pendingDose.expectedMinute}'),
      ));
    }

    // 4. Estoque de medicação baixo.
    final lowDays = lowStock?.daysOfStockRemaining;
    if (lowStock != null && lowDays != null && lowDays <= 7) {
      alerts.add(_AlertData(
        id: 'low-stock-${lowStock.id}',
        accent: AppColors.tertiary,
        badge: AppColors.tertiaryContainer.withValues(alpha: 0.5),
        badgeFg: AppColors.onTertiaryContainer,
        icon: Icons.inventory_2,
        title: 'Estoque acabando',
        meta: 'ESTOQUE BAIXO',
        body:
            'Seu estoque de ${lowStock.name} dura cerca de $lowDays ${lowDays == 1 ? 'dia' : 'dias'}. Programe a reposição para não interromper o tratamento.',
        infoRow: [
          ('Medicação', lowStock.name),
          ('Restante', '$lowDays ${lowDays == 1 ? 'dia' : 'dias'}'),
        ],
        primaryLabel: 'Ver Medicamentos',
        primaryColor: AppColors.tertiaryFixedDim,
        onPrimary: () => context.push(AppRoutes.medicationHistory),
        secondaryLabel: 'Ignorar',
        onSecondary: () => _dismiss('low-stock-${lowStock.id}'),
      ));
    }

    // 5. Conquista: controle dentro do alvo na última semana.
    if (stats.count >= 3 && stats.timeInRangePct >= 70) {
      alerts.add(_AlertData(
        id: 'goal-achieved',
        accent: AppColors.secondary,
        badge: AppColors.secondaryContainer,
        badgeFg: AppColors.onSecondaryContainer,
        icon: Icons.workspace_premium,
        title: 'Parabéns! Você está no controle',
        meta: 'ÚLTIMOS 7 DIAS',
        body:
            'Você manteve ${stats.timeInRangePct.toStringAsFixed(0)}% das medições dentro da faixa alvo. Continue assim!',
        statsGrid: [
          ('NO ALVO', '${stats.timeInRangePct.toStringAsFixed(0)}%'),
          (
            'VARIABILIDADE',
            stats.stdDev <= 35 ? 'Baixa' : 'Alta',
          ),
        ],
        shareLabel: 'Compartilhar Progresso',
        onShare: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Você manteve ${stats.timeInRangePct.toStringAsFixed(0)}% no alvo nos últimos 7 dias 🎉',
            ),
            backgroundColor: AppColors.secondary,
          ),
        ),
      ));
    }

    return alerts;
  }

  String _formatAgo(DateTime when, DateTime now) {
    final diff = now.difference(when);
    if (diff.inMinutes < 1) return 'AGORA';
    if (diff.inMinutes < 60) return 'HÁ ${diff.inMinutes} MIN';
    if (diff.inHours < 24) return 'HÁ ${diff.inHours}H';
    return 'HÁ ${diff.inDays} ${diff.inDays == 1 ? 'DIA' : 'DIAS'}';
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppColors.softShadow(),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle,
                color: AppColors.secondary, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'Tudo em ordem',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Você está sem alertas pendentes. Vamos manter assim!',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertData {
  _AlertData({
    required this.id,
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
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.shareLabel,
    this.onShare,
  });

  final String id;
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
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final String? shareLabel;
  final VoidCallback? onShare;
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.data});

  final _AlertData data;

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
                  color: data.badge,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(data.icon, color: data.badgeFg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: data.accent,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.meta,
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color:
                            AppColors.onSurfaceVariant.withValues(alpha: 0.7),
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
            data.body,
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          if (data.recommendations != null) ...[
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
                  ...data.recommendations!.map((r) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(r.$2, color: data.accent, size: 16),
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
          if (data.infoRow != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < data.infoRow!.length; i++) ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.infoRow![i].$1,
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            data.infoRow![i].$2,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < data.infoRow!.length - 1)
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
          if (data.statsGrid != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                for (var i = 0; i < data.statsGrid!.length; i++) ...[
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
                            data.statsGrid![i].$1,
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurfaceVariant,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data.statsGrid![i].$2,
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
          if (data.shareLabel != null) ...[
            const SizedBox(height: 16),
            Center(
              child: InkWell(
                onTap: data.onShare,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.share, color: data.accent, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        data.shareLabel!,
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w800,
                          color: data.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (data.primaryLabel != null) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            data.primaryColor ?? AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(99)),
                      ),
                      onPressed: data.onPrimary,
                      child: Text(
                        data.primaryLabel!,
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
                if (data.secondaryLabel != null) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: AppColors.outlineVariant
                                .withValues(alpha: 0.4),
                            width: 2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(99)),
                        foregroundColor: AppColors.onSurfaceVariant,
                      ),
                      onPressed: data.onSecondary,
                      child: Text(
                        data.secondaryLabel!,
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800),
                      ),
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
