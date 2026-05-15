import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../analytics/data/glucose_analytics.dart';
import '../../analytics/presentation/analytics_providers.dart';
import '../../glucose_log/data/glucose_reading.dart';
import '../../glucose_log/presentation/glucose_providers.dart';

class EvolutionChartsPage extends ConsumerStatefulWidget {
  const EvolutionChartsPage({super.key});

  @override
  ConsumerState<EvolutionChartsPage> createState() =>
      _EvolutionChartsPageState();
}

class _EvolutionChartsPageState extends ConsumerState<EvolutionChartsPage> {
  int _days = 30;

  @override
  Widget build(BuildContext context) {
    final readings = ref.watch(recentGlucoseReadingsProvider);
    final stats = ref.watch(glucoseStatsProvider(_days));
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
                      child:
                          Icon(Icons.person, color: AppColors.onSurfaceVariant),
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
                    const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.primary,
                    ),
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
                'Acompanhe seu progresso de glicemia ao longo do tempo.',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              _RangeSelector(
                selected: _days,
                onSelect: (d) => setState(() => _days = d),
              ),
              const SizedBox(height: 24),
              readings.when(
                loading: () => const _LoadingBlock(),
                error: (e, _) => _ErrorBlock(message: '$e'),
                data: (allReadings) {
                  final inRange = _filterByDays(allReadings, _days);
                  return stats.when(
                    loading: () => const _LoadingBlock(),
                    error: (e, _) => _ErrorBlock(message: '$e'),
                    data: (s) {
                      if (!s.hasData) {
                        return const _EmptyBlock();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SummaryCard(stats: s),
                          const SizedBox(height: 16),
                          _ChartCard(readings: inRange, stats: s, days: _days),
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
                          _TrendCard(stats: s),
                          const SizedBox(height: 16),
                          _StatChipsRow(stats: s),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<GlucoseReading> _filterByDays(
    List<GlucoseReading> readings,
    int days,
  ) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return readings.where((r) => r.measuredAt.isAfter(cutoff)).toList();
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.selected, required this.onSelect});
  final int selected;
  final ValueChanged<int> onSelect;

  static const _options = [7, 30, 90];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _options
            .map((d) => _RangeChip(
                  label: '$d dias',
                  selected: selected == d,
                  onTap: () => onSelect(d),
                ))
            .toList(),
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
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
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.stats});
  final GlucoseStats stats;

  @override
  Widget build(BuildContext context) {
    final delta = stats.deltaFromPrevious;
    return Container(
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
                '${stats.average.round()}',
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniStat(
                label: 'MEDIÇÕES',
                value: '${stats.count}',
                color: AppColors.primary,
              ),
              _MiniStat(
                label: 'TIR',
                value: '${stats.timeInRangePct.toStringAsFixed(0)}%',
                color: AppColors.secondary,
              ),
              _MiniStat(
                label: 'MÍN',
                value: '${stats.min}',
                color: AppColors.onSurfaceVariant,
              ),
              _MiniStat(
                label: 'MÁX',
                value: '${stats.max}',
                color: AppColors.onSurfaceVariant,
              ),
              if (delta != null)
                _DeltaBadge(delta: delta),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge({required this.delta});
  final double delta;

  @override
  Widget build(BuildContext context) {
    final improved = delta < 0;
    final color = improved ? AppColors.secondary : AppColors.error;
    final sign = delta > 0 ? '+' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            improved ? Icons.trending_down : Icons.trending_up,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '$sign${delta.toStringAsFixed(1)} vs anterior',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.readings,
    required this.stats,
    required this.days,
  });
  final List<GlucoseReading> readings;
  final GlucoseStats stats;
  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              _Legend(
                label: 'FAIXA ALVO',
                color: AppColors.secondary.withValues(alpha: 0.4),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: _GlucoseLineChart(readings: readings, days: days),
          ),
        ],
      ),
    );
  }
}

class _GlucoseLineChart extends StatelessWidget {
  const _GlucoseLineChart({required this.readings, required this.days});
  final List<GlucoseReading> readings;
  final int days;

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return Center(
        child: Text(
          'Sem medições no período.',
          style: GoogleFonts.manrope(color: AppColors.onSurfaceVariant),
        ),
      );
    }
    final sorted = [...readings]
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    final start = DateTime.now()
        .subtract(Duration(days: days))
        .millisecondsSinceEpoch
        .toDouble();
    final end = DateTime.now().millisecondsSinceEpoch.toDouble();
    final spots = sorted
        .map((r) => FlSpot(
              r.measuredAt.millisecondsSinceEpoch.toDouble(),
              r.valueMgdl.toDouble(),
            ))
        .toList();
    final maxY = sorted
        .map((r) => r.valueMgdl)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final minY = sorted
        .map((r) => r.valueMgdl)
        .reduce((a, b) => a < b ? a : b)
        .toDouble();
    final chartMaxY = maxY < 200 ? 200.0 : (maxY + 20).ceilToDouble();
    final chartMinY = minY > 60 ? 60.0 : (minY - 10).floorToDouble();

    return LineChart(
      LineChartData(
        minX: start,
        maxX: end,
        minY: chartMinY,
        maxY: chartMaxY,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 40,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.surfaceContainerHighest,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        rangeAnnotations: RangeAnnotations(
          horizontalRangeAnnotations: [
            HorizontalRangeAnnotation(
              y1: 70,
              y2: 140,
              color: AppColors.secondary.withValues(alpha: 0.1),
            ),
          ],
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 40,
              getTitlesWidget: (value, _) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  value.toInt().toString(),
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: (end - start) / 4,
              getTitlesWidget: (value, _) {
                final d = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormat('dd/MM').format(d),
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.onSurface.withValues(alpha: 0.9),
            getTooltipItems: (spots) => spots
                .map((s) {
                  final d =
                      DateTime.fromMillisecondsSinceEpoch(s.x.toInt());
                  return LineTooltipItem(
                    '${s.y.toInt()} mg/dL\n${DateFormat('dd/MM HH:mm').format(d)}',
                    GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  );
                })
                .toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.25,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeColor: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.18),
                  AppColors.primary.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.stats});
  final GlucoseStats stats;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (stats.trend) {
      TrendDirection.melhorando => (AppColors.secondary, Icons.trending_down),
      TrendDirection.piorando => (AppColors.error, Icons.trending_up),
      TrendDirection.estavel => (AppColors.primary, Icons.show_chart),
      TrendDirection.semDados => (AppColors.outline, Icons.help_outline),
    };
    final headline = buildHeadline(stats);
    final secondary = buildSecondaryInsight(stats) ?? '';
    return Container(
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
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      stats.trend.label,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: color,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  headline,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                if (secondary.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    secondary,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
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

class _StatChipsRow extends StatelessWidget {
  const _StatChipsRow({required this.stats});
  final GlucoseStats stats;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    if (stats.timeInRangePct >= 70) {
      chips.add(
        _Chip(
          label: 'TIR alto',
          icon: Icons.check_circle,
          fg: AppColors.onSecondaryContainer,
          bg: AppColors.secondaryContainer,
        ),
      );
    } else if (stats.timeInRangePct < 50) {
      chips.add(
        _Chip(
          label: 'TIR baixo',
          icon: Icons.warning,
          fg: Colors.white,
          bg: AppColors.tertiaryFixedDim,
        ),
      );
    }
    if (stats.stdDev > 35) {
      chips.add(
        _Chip(
          label: 'Variabilidade alta',
          icon: Icons.swap_vert,
          fg: Colors.white,
          bg: AppColors.tertiaryFixedDim,
        ),
      );
    } else if (stats.count >= 3 && stats.stdDev < 20) {
      chips.add(
        _Chip(
          label: 'Estável',
          icon: Icons.check_circle,
          fg: AppColors.onSecondaryContainer,
          bg: AppColors.secondaryContainer,
        ),
      );
    }
    if (stats.max > 200) {
      chips.add(
        _Chip(
          label: 'Picos detectados',
          icon: Icons.show_chart,
          fg: Colors.white,
          bg: AppColors.error,
        ),
      );
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8, runSpacing: 8, children: chips);
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
  const _Chip({
    required this.label,
    required this.icon,
    required this.fg,
    required this.bg,
  });
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

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 64),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bloodtype,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sem dados no período',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Registre medições de glicemia para ver gráficos e tendências aqui.',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 36),
            const SizedBox(height: 12),
            Text(
              'Falha ao carregar dados',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
