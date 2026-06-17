import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../analytics/data/glucose_analytics.dart';
import '../../glucose_log/data/glucose_reading.dart';
import '../../meal_log/data/meal_log.dart';
import '../../medication/data/medication_adherence.dart';
import '../../medication/data/medication_schedule.dart';
import '../data/doctor_repository.dart';
import '../data/patient_data.dart';
import 'doctor_actions.dart';
import 'doctor_chat_panel.dart';

class DoctorDashboardPage extends StatelessWidget {
  const DoctorDashboardPage({
    super.key,
    required this.patient,
    required this.repo,
    required this.onLogout,
    required this.onRefresh,
  });

  final PatientData patient;
  final DoctorRepository repo;
  final VoidCallback onLogout;
  final Future<void> Function() onRefresh;

  String get _doctorName {
    final name = patient.careTeam.doctorName;
    return (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : 'Equipe de saúde';
  }

  @override
  Widget build(BuildContext context) {
    final team = patient.careTeam;
    final stats = computeStats(patient.glucose, days: 7);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopBar(patient: patient, onLogout: onLogout),
                  const SizedBox(height: 24),
                  _PatientHeader(patient: patient),
                  const SizedBox(height: 16),
                  DoctorActionsBar(
                    onPrescribe: () => showPrescribeDialog(
                      context,
                      repo: repo,
                      uid: patient.uid,
                      doctorName: _doctorName,
                      onDone: onRefresh,
                    ),
                    onAddNote: () => showCareNoteDialog(
                      context,
                      repo: repo,
                      uid: patient.uid,
                      doctorName: _doctorName,
                      onDone: onRefresh,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Glicemia.
                  _SectionTitle(
                    icon: Icons.bloodtype,
                    title: 'Controle Glicêmico',
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  if (!patient.shareGlucose)
                    const _NotShared(label: 'Histórico de glicemia')
                  else if (patient.glucose.isEmpty)
                    const _EmptySection(
                        label: 'Sem medições de glicemia registradas.')
                  else ...[
                    _GlucoseStats(stats: stats),
                    const SizedBox(height: 16),
                    _GlucoseChartCard(readings: patient.glucose),
                    const SizedBox(height: 16),
                    _RecentReadings(readings: patient.glucose),
                  ],
                  const SizedBox(height: 32),

                  // Medicação.
                  _SectionTitle(
                    icon: Icons.medication,
                    title: 'Adesão à Medicação',
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: 12),
                  if (!patient.shareMedication)
                    const _NotShared(label: 'Uso de medicamentos')
                  else if (patient.schedules.isEmpty)
                    const _EmptySection(
                        label: 'Nenhum medicamento cadastrado.')
                  else
                    _MedicationSection(patient: patient),
                  const SizedBox(height: 32),

                  // Alimentação.
                  _SectionTitle(
                    icon: Icons.restaurant_menu,
                    title: 'Registro Alimentar',
                    color: AppColors.tertiary,
                  ),
                  const SizedBox(height: 12),
                  if (!patient.shareMeals)
                    const _NotShared(label: 'Registro alimentar')
                  else if (patient.meals.isEmpty)
                    const _EmptySection(
                        label: 'Nenhuma refeição registrada.')
                  else
                    _MealsSection(meals: patient.meals),
                  const SizedBox(height: 32),

                  // Chat em tempo real.
                  _SectionTitle(
                    icon: Icons.chat_bubble_outline,
                    title: 'Conversa com o paciente',
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  DoctorChatPanel(
                    repo: repo,
                    uid: patient.uid,
                    doctorName: _doctorName,
                  ),
                  const SizedBox(height: 32),

                  Center(
                    child: Text(
                      'Glicare • Painel Clínico — dados compartilhados pelo paciente',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (team.updatedAt != null) ...[
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        'Equipe atualizada em ${DateFormat('dd/MM/yyyy HH:mm').format(team.updatedAt!)}',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.patient, required this.onLogout});
  final PatientData patient;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.favorite, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Glicare',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
            Text(
              'Painel Clínico',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout, size: 18),
          label: const Text('Sair'),
        ),
      ],
    );
  }
}

class _PatientHeader extends StatelessWidget {
  const _PatientHeader({required this.patient});
  final PatientData patient;

  @override
  Widget build(BuildContext context) {
    final team = patient.careTeam;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow(),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.person, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paciente',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (patient.profile.hasPhone) patient.profile.phone,
                    if (team.hasUbs) team.ubsName,
                  ].whereType<String>().join(' • '),
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (team.hasDoctor) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Acompanhamento: ${team.doctorName}'
                    '${team.doctorSpecialty != null ? ' • ${team.doctorSpecialty}' : ''}',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield, size: 14, color: AppColors.secondary),
                const SizedBox(width: 4),
                Text(
                  'Acesso autorizado',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondary,
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

class _GlucoseStats extends StatelessWidget {
  const _GlucoseStats({required this.stats});
  final GlucoseStats stats;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _StatCard(
          label: 'MÉDIA (7 DIAS)',
          value: '${stats.average.round()}',
          unit: 'mg/dL',
          color: AppColors.primary,
        ),
        _StatCard(
          label: 'TEMPO NO ALVO',
          value: stats.timeInRangePct.toStringAsFixed(0),
          unit: '%',
          color: AppColors.secondary,
        ),
        _StatCard(
          label: 'MÍN / MÁX',
          value: '${stats.min}/${stats.max}',
          unit: 'mg/dL',
          color: AppColors.tertiary,
        ),
        _StatCard(
          label: 'TENDÊNCIA',
          value: stats.trend.label,
          unit: '',
          color: AppColors.onSurface,
        ),
        _StatCard(
          label: 'VARIABILIDADE (DP)',
          value: stats.stdDev.toStringAsFixed(0),
          unit: 'mg/dL',
          color: AppColors.tertiaryFixedDim,
        ),
        _StatCard(
          label: 'MEDIÇÕES',
          value: '${stats.count}',
          unit: '',
          color: AppColors.onSurfaceVariant,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });
  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow(opacity: 0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: -1,
                  ),
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _GlucoseChartCard extends StatelessWidget {
  const _GlucoseChartCard({required this.readings});
  final List<GlucoseReading> readings;

  @override
  Widget build(BuildContext context) {
    final sorted = [...readings]
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    final recent = sorted.length > 60
        ? sorted.sublist(sorted.length - 60)
        : sorted;
    final spots = recent
        .map((r) => FlSpot(
              r.measuredAt.millisecondsSinceEpoch.toDouble(),
              r.valueMgdl.toDouble(),
            ))
        .toList();
    final maxV = recent.map((r) => r.valueMgdl).reduce((a, b) => a > b ? a : b);
    final minV = recent.map((r) => r.valueMgdl).reduce((a, b) => a < b ? a : b);
    final chartMaxY = (maxV < 200 ? 200 : maxV + 20).toDouble();
    final chartMinY = (minV > 60 ? 60 : minV - 10).toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow(opacity: 0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              'Curva glicêmica recente (faixa alvo 70–140)',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: LineChart(
              LineChartData(
                minY: chartMinY,
                maxY: chartMaxY,
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 40,
                  getDrawingHorizontalLine: (_) => const FlLine(
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
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      interval: 40,
                      getTitlesWidget: (value, _) => Text(
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
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.08),
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

class _RecentReadings extends StatelessWidget {
  const _RecentReadings({required this.readings});
  final List<GlucoseReading> readings;

  @override
  Widget build(BuildContext context) {
    final recent = readings.take(8).toList();
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow(opacity: 0.03),
      ),
      child: Column(
        children: [
          for (final r in recent) _ReadingRow(reading: r),
        ],
      ),
    );
  }
}

class _ReadingRow extends StatelessWidget {
  const _ReadingRow({required this.reading});
  final GlucoseReading reading;

  @override
  Widget build(BuildContext context) {
    final range = rangeFor(reading.valueMgdl);
    final color = switch (range) {
      GlucoseRange.hipo => AppColors.error,
      GlucoseRange.normal => AppColors.secondary,
      GlucoseRange.elevada => AppColors.tertiaryFixedDim,
      GlucoseRange.hiper => AppColors.error,
    };
    return ListTile(
      leading: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      title: Text(
        '${reading.valueMgdl} mg/dL',
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          color: AppColors.onSurface,
        ),
      ),
      subtitle: Text(
        DateFormat("dd/MM 'às' HH:mm").format(reading.measuredAt),
        style: GoogleFonts.manrope(
          fontSize: 12,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      trailing: Text(
        range.label,
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _MedicationSection extends StatelessWidget {
  const _MedicationSection({required this.patient});
  final PatientData patient;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final adherence = computeWeeklyAdherence(
      schedules: patient.schedules,
      logs: patient.medicationLogs,
      now: now,
    );
    final doses = buildDosesForDay(
      day: now,
      schedules: patient.schedules,
      logs: patient.medicationLogs,
      now: now,
    );
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow(opacity: 0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Adesão semanal',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                adherence.hasData
                    ? '${adherence.percentage.toStringAsFixed(0)}%'
                    : '—',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          if (adherence.hasData) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: (adherence.percentage / 100).clamp(0, 1),
                minHeight: 8,
                backgroundColor: AppColors.surfaceContainerHigh,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.secondary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${adherence.confirmed} de ${adherence.expected} doses confirmadas nos últimos 7 dias',
              style: GoogleFonts.manrope(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Text(
            'MEDICAMENTOS',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          for (final s in patient.schedules) _ScheduleRow(schedule: s),
          if (doses.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text(
              'DOSES DE HOJE',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            for (final d in doses) _DoseRow(dose: d),
          ],
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.schedule});
  final MedicationSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final times = schedule.timesOfDay.map(formatMinutes).join(', ');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.medication_outlined,
          color: AppColors.secondary),
      title: Text(
        '${schedule.name}${schedule.dosage.isNotEmpty ? ' • ${schedule.dosage}' : ''}',
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      ),
      subtitle: Text(
        times.isEmpty ? 'Sem horários definidos' : 'Horários: $times',
        style: GoogleFonts.manrope(
          fontSize: 12,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      trailing: schedule.isPendingPrescription
          ? Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.tertiaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                'AGUARDANDO',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.tertiary,
                  letterSpacing: 1,
                ),
              ),
            )
          : (schedule.daysOfStockRemaining != null
              ? Text(
                  '${schedule.daysOfStockRemaining}d estoque',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                  ),
                )
              : null),
    );
  }
}

class _DoseRow extends StatelessWidget {
  const _DoseRow({required this.dose});
  final ScheduledDose dose;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (dose.status) {
      DoseStatus.realizado => ('Confirmada', AppColors.secondary),
      DoseStatus.agendado => ('Agendada', AppColors.onSurfaceVariant),
      DoseStatus.pendente => ('Pendente', AppColors.tertiaryFixedDim),
      DoseStatus.atrasado => ('Atrasada', AppColors.error),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            formatMinutes(dose.expectedMinute),
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              dose.schedule.name,
              style: GoogleFonts.manrope(
                color: AppColors.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealsSection extends StatelessWidget {
  const _MealsSection({required this.meals});
  final List<MealLog> meals;

  @override
  Widget build(BuildContext context) {
    final recent = meals.take(10).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow(opacity: 0.03),
      ),
      child: Column(
        children: [
          for (final m in recent) _MealRow(meal: m),
        ],
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({required this.meal});
  final MealLog meal;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: const Icon(Icons.restaurant_menu, color: AppColors.tertiary),
      title: Text(
        '${meal.category.label} • ${DateFormat('dd/MM HH:mm').format(meal.eatenAt)}',
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      ),
      subtitle: meal.items.isEmpty
          ? null
          : Text(
              meal.items.join(', '),
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
      trailing: meal.glucoseMgdl != null
          ? Text(
              '${meal.glucoseMgdl} mg/dL',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            )
          : null,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.color,
  });
  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _NotShared extends StatelessWidget {
  const _NotShared({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label não foi compartilhado por este paciente.',
              style: GoogleFonts.manrope(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow(opacity: 0.03),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(color: AppColors.onSurfaceVariant),
      ),
    );
  }
}
