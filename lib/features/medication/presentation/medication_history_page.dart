import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glicare_app_bar.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/medication_adherence.dart';
import '../data/medication_log.dart';
import '../data/medication_schedule.dart';
import 'medication_log_providers.dart';

class MedicationHistoryPage extends ConsumerStatefulWidget {
  const MedicationHistoryPage({super.key});

  @override
  ConsumerState<MedicationHistoryPage> createState() =>
      _MedicationHistoryPageState();
}

class _MedicationHistoryPageState extends ConsumerState<MedicationHistoryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GlicareAppBar(title: 'Medicações'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push(AppRoutes.medicationRegister),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: _TabSelector(controller: _tabs),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: const [
                  _TodayTab(),
                  _PastTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabSelector extends StatelessWidget {
  const _TabSelector({required this.controller});
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.onSurfaceVariant,
        labelStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
        unselectedLabelStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
        tabs: const [
          Tab(text: 'Hoje'),
          Tab(text: 'Anteriores'),
        ],
      ),
    );
  }
}

class _TodayTab extends ConsumerWidget {
  const _TodayTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dosesAsync = ref.watch(todaysDosesProvider);
    final adherenceAsync = ref.watch(weeklyAdherenceProvider);
    final stockAsync = ref.watch(lowestStockScheduleProvider);
    final schedulesAsync = ref.watch(medicationSchedulesProvider);

    return dosesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(message: '$e'),
      data: (doses) {
        final schedules = schedulesAsync.asData?.value ?? const [];
        final pending =
            schedules.where((s) => s.isPendingPrescription).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
          children: [
            if (pending.isNotEmpty) ...[
              _PrescriptionsHeader(count: pending.length),
              const SizedBox(height: 12),
              for (final s in pending) ...[
                _PrescriptionCard(
                  schedule: s,
                  onConfirm: () => _confirmPrescription(context, ref, s),
                  onDecline: () => _declinePrescription(context, ref, s),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 16),
            ],
            Text(
              'Doses de hoje',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _todaySubtitle(doses),
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            if (schedules.isEmpty)
              const _NoSchedulesState()
            else if (doses.isEmpty)
              const _NoTodayDosesState()
            else
              ..._buildTimeline(context, ref, doses),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(child: _AdherenceCard(stats: adherenceAsync)),
                const SizedBox(width: 16),
                Expanded(child: _StockSummaryCard(state: stockAsync)),
              ],
            ),
          ],
        );
      },
    );
  }

  String _todaySubtitle(List<ScheduledDose> doses) {
    if (doses.isEmpty) return 'Nada agendado para hoje.';
    final done = doses.where((d) => d.status == DoseStatus.realizado).length;
    return '$done de ${doses.length} concluídas hoje.';
  }

  Future<void> _confirmPrescription(
    BuildContext context,
    WidgetRef ref,
    MedicationSchedule schedule,
  ) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final updated = schedule.copyWith(confirmed: true, active: true);
    try {
      await ref
          .read(medicationScheduleRepositoryProvider)
          .update(uid: user.uid, schedule: updated);
      await ref.read(medicationNotificationsProvider).syncSchedule(updated);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${schedule.name} confirmada e ativada.'),
          backgroundColor: AppColors.secondary,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao confirmar: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _declinePrescription(
    BuildContext context,
    WidgetRef ref,
    MedicationSchedule schedule,
  ) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Recusar prescrição'),
        content: Text(
          'Recusar a prescrição de ${schedule.name}? Converse com seu médico antes de recusar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Recusar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(medicationScheduleRepositoryProvider)
          .delete(uid: user.uid, scheduleId: schedule.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prescrição recusada.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao recusar: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  List<Widget> _buildTimeline(
    BuildContext context,
    WidgetRef ref,
    List<ScheduledDose> doses,
  ) {
    final entries = <Widget>[];
    for (var i = 0; i < doses.length; i++) {
      entries.add(_DoseEntry(
        dose: doses[i],
        onConfirm: () => _confirmDose(context, ref, doses[i]),
      ));
      if (i < doses.length - 1) entries.add(const SizedBox(height: 16));
    }
    return entries;
  }

  Future<void> _confirmDose(
    BuildContext context,
    WidgetRef ref,
    ScheduledDose dose,
  ) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      await ref.read(medicationLogRepositoryProvider).create(
            uid: user.uid,
            name: dose.schedule.name,
            takenAt: DateTime.now(),
            dosage: dose.schedule.dosage.isEmpty ? null : dose.schedule.dosage,
            scheduleId: dose.schedule.id,
            expectedMinute: dose.expectedMinute,
          );
      if (dose.schedule.tracksStock) {
        await ref
            .read(medicationScheduleRepositoryProvider)
            .decrementStock(
              uid: user.uid,
              scheduleId: dose.schedule.id,
              pills: dose.schedule.pillsPerDose!,
            );
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${dose.schedule.name} confirmada.'),
          backgroundColor: AppColors.secondary,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao confirmar: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class _DoseEntry extends StatelessWidget {
  const _DoseEntry({required this.dose, required this.onConfirm});
  final ScheduledDose dose;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final time = formatMinutes(dose.expectedMinute);
    final (statusBg, statusFg, statusIcon, statusText) = _statusVisuals(dose.status);
    final isDimmed = dose.status == DoseStatus.agendado;
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
              child: Icon(statusIcon, color: statusFg),
            ),
            const SizedBox(width: 12),
            Text(
              '${statusText.toUpperCase()} • $time',
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
          child: Opacity(
            opacity: isDimmed ? 0.7 : 1,
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
                              dose.schedule.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onSurface,
                              ),
                            ),
                            if (dose.schedule.dosage.isNotEmpty)
                              Text(
                                dose.schedule.dosage,
                                style: GoogleFonts.manrope(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      _StatusBadge(text: statusText, fg: statusFg, bg: statusBg),
                    ],
                  ),
                  if (dose.status == DoseStatus.realizado && dose.log != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.check, size: 14, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Text(
                          'Confirmada às ${DateFormat('HH:mm').format(dose.log!.takenAt)}',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (dose.status == DoseStatus.pendente ||
                      dose.status == DoseStatus.atrasado) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: onConfirm,
                            child: Text(
                              'Confirmar Dose',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  (Color, Color, IconData, String) _statusVisuals(DoseStatus status) {
    return switch (status) {
      DoseStatus.realizado => (
          AppColors.secondaryContainer,
          AppColors.secondary,
          Icons.check_circle,
          'Tomado',
        ),
      DoseStatus.pendente => (
          AppColors.tertiaryContainer.withValues(alpha: 0.4),
          AppColors.tertiary,
          Icons.schedule,
          'Pendente',
        ),
      DoseStatus.atrasado => (
          AppColors.error.withValues(alpha: 0.18),
          AppColors.error,
          Icons.warning_amber,
          'Atrasado',
        ),
      DoseStatus.agendado => (
          AppColors.surfaceContainerHighest,
          AppColors.onSurfaceVariant,
          Icons.medication,
          'Agendado',
        ),
    };
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text, required this.fg, required this.bg});
  final String text;
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
        text.toUpperCase(),
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

class _AdherenceCard extends StatelessWidget {
  const _AdherenceCard({required this.stats});
  final AsyncValue<AdherenceStats> stats;

  @override
  Widget build(BuildContext context) {
    final value = stats.asData?.value;
    final hasData = value?.hasData ?? false;
    final percent = value?.percentage ?? 0;
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
          if (!hasData)
            Text(
              '—',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                height: 1,
              ),
            )
          else
            Text(
              '${percent.round()}%',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                letterSpacing: -2,
                height: 1,
              ),
            ),
          Text(
            hasData
                ? '${value!.confirmed}/${value.expected} doses esperadas nos últimos 7 dias.'
                : 'Sem doses esperadas nos últimos 7 dias.',
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

class _StockSummaryCard extends StatelessWidget {
  const _StockSummaryCard({required this.state});
  final AsyncValue<MedicationSchedule?> state;

  @override
  Widget build(BuildContext context) {
    final schedule = state.asData?.value;
    final days = schedule?.daysOfStockRemaining;
    final low = days != null && days <= 7;
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
          if (schedule == null)
            Text(
              'Sem controle ativo.',
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            )
          else ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        schedule.name,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      '${days ?? 0} ${days == 1 ? 'dia' : 'dias'}',
                      style: GoogleFonts.manrope(
                        color: low ? AppColors.error : AppColors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: ((days ?? 0) / 30).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.5),
                    valueColor: AlwaysStoppedAnimation(
                      low ? AppColors.error : AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '${schedule.pillsRemaining} comprimidos restantes.',
              style: GoogleFonts.manrope(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PastTab extends ConsumerWidget {
  const _PastTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(recentMedicationLogsProvider);
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    return logs.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(message: '$e'),
      data: (items) {
        final past = items.where((l) => l.takenAt.isBefore(todayStart)).toList();
        if (past.isEmpty) return const _NoPastLogsState();
        final grouped = _groupByDay(past);
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final group = grouped[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index > 0) const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(
                    group.label.toUpperCase(),
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.6,
                    ),
                  ),
                ),
                for (final log in group.logs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LogCard(
                      log: log,
                      onDelete: () => _confirmDelete(context, ref, log),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MedicationLog log,
  ) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir registro'),
        content: Text(
          'Remover este registro de ${log.name}? Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(medicationLogRepositoryProvider)
          .delete(uid: user.uid, logId: log.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro removido.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao remover: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  List<_DayGroup> _groupByDay(List<MedicationLog> logs) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1));
    final result = <String, _DayGroup>{};
    for (final log in logs) {
      final d = log.takenAt;
      final dayKey = DateTime(d.year, d.month, d.day);
      final keyStr = dayKey.toIso8601String();
      final label =
          dayKey == yesterday ? 'Ontem' : _formatDay(dayKey);
      result
          .putIfAbsent(keyStr, () => _DayGroup(label: label, logs: []))
          .logs
          .add(log);
    }
    return result.values.toList();
  }

  String _formatDay(DateTime dt) {
    try {
      return DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(dt);
    } catch (_) {
      return DateFormat('dd/MM/yyyy').format(dt);
    }
  }
}

class _DayGroup {
  _DayGroup({required this.label, required this.logs});
  final String label;
  final List<MedicationLog> logs;
}

class _LogCard extends StatelessWidget {
  const _LogCard({required this.log, required this.onDelete});
  final MedicationLog log;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final timeFormatter = DateFormat('HH:mm');
    final dosage = log.dosage?.trim();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow(),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.medication, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  timeFormatter.format(log.takenAt),
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (log.notes != null && log.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    log.notes!,
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
          if (dosage != null && dosage.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                dosage,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline,
                color: AppColors.onSurfaceVariant),
            tooltip: 'Excluir',
          ),
        ],
      ),
    );
  }
}

class _PrescriptionsHeader extends StatelessWidget {
  const _PrescriptionsHeader({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.verified_user, color: AppColors.secondary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Prescrições do seu médico',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            '$count nova${count > 1 ? 's' : ''}',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  const _PrescriptionCard({
    required this.schedule,
    required this.onConfirm,
    required this.onDecline,
  });

  final MedicationSchedule schedule;
  final VoidCallback onConfirm;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final times = schedule.timesOfDay.map(formatMinutes).join(', ');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.medication, color: AppColors.secondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (schedule.dosage.isNotEmpty)
                      Text(
                        schedule.dosage,
                        style: GoogleFonts.manrope(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule,
                  size: 14, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                times.isEmpty ? 'Sem horários' : times,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Prescrito por ${schedule.prescriberName}',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: onConfirm,
                  child: Text(
                    'Confirmar',
                    style:
                        GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.onSurfaceVariant,
                  side: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onDecline,
                child: Text(
                  'Recusar',
                  style:
                      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoSchedulesState extends StatelessWidget {
  const _NoSchedulesState();

  @override
  Widget build(BuildContext context) {
    return _StateCard(
      icon: Icons.medication_outlined,
      iconColor: AppColors.primary,
      title: 'Nenhuma medicação cadastrada',
      body: 'Toque no botão "+" para adicionar sua primeira medicação.',
    );
  }
}

class _NoTodayDosesState extends StatelessWidget {
  const _NoTodayDosesState();

  @override
  Widget build(BuildContext context) {
    return _StateCard(
      icon: Icons.check_circle,
      iconColor: AppColors.secondary,
      title: 'Sem doses hoje',
      body: 'Suas medicações cadastradas não têm doses programadas para hoje.',
    );
  }
}

class _NoPastLogsState extends StatelessWidget {
  const _NoPastLogsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: _StateCard(
          icon: Icons.history,
          iconColor: AppColors.primary,
          title: 'Sem registros anteriores',
          body:
              'Doses confirmadas aparecerão aqui assim que você começar a usar.',
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow(),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 36, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              'Não foi possível carregar',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
