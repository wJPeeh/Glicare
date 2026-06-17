import 'medication_log.dart';
import 'medication_schedule.dart';

enum DoseStatus { realizado, pendente, agendado, atrasado }

class ScheduledDose {
  const ScheduledDose({
    required this.schedule,
    required this.scheduledAt,
    required this.expectedMinute,
    required this.status,
    this.log,
  });

  final MedicationSchedule schedule;
  final DateTime scheduledAt;
  final int expectedMinute;
  final DoseStatus status;
  final MedicationLog? log;
}

const Duration _matchWindow = Duration(hours: 2);
const Duration _lateThreshold = Duration(minutes: 30);

List<ScheduledDose> buildDosesForDay({
  required DateTime day,
  required List<MedicationSchedule> schedules,
  required List<MedicationLog> logs,
  required DateTime now,
}) {
  final dayStart = DateTime(day.year, day.month, day.day);
  final dayEnd = dayStart.add(const Duration(days: 1));
  final dayLogs = logs
      .where((l) => !l.takenAt.isBefore(dayStart) && l.takenAt.isBefore(dayEnd))
      .toList();
  final usedLogIds = <String>{};
  final doses = <ScheduledDose>[];

  for (final schedule in schedules) {
    if (!schedule.occursOn(dayStart)) continue;
    for (final minute in schedule.timesOfDay) {
      final scheduledAt = dayStart.add(Duration(minutes: minute));
      final log = _findMatchingLog(
        schedule: schedule,
        minute: minute,
        scheduledAt: scheduledAt,
        logs: dayLogs,
        used: usedLogIds,
      );
      if (log != null) usedLogIds.add(log.id);
      doses.add(ScheduledDose(
        schedule: schedule,
        scheduledAt: scheduledAt,
        expectedMinute: minute,
        status: _statusFor(scheduledAt: scheduledAt, log: log, now: now),
        log: log,
      ));
    }
  }

  doses.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  return doses;
}

MedicationLog? _findMatchingLog({
  required MedicationSchedule schedule,
  required int minute,
  required DateTime scheduledAt,
  required List<MedicationLog> logs,
  required Set<String> used,
}) {
  MedicationLog? best;
  Duration bestDelta = _matchWindow + const Duration(seconds: 1);
  for (final log in logs) {
    if (used.contains(log.id)) continue;
    final scheduleMatches = log.scheduleId == schedule.id;
    final nameMatches = log.scheduleId == null &&
        log.name.toLowerCase() == schedule.name.toLowerCase();
    if (!scheduleMatches && !nameMatches) continue;
    final delta = log.takenAt.difference(scheduledAt).abs();
    if (delta > _matchWindow) continue;
    if (delta < bestDelta) {
      best = log;
      bestDelta = delta;
    }
  }
  return best;
}

DoseStatus _statusFor({
  required DateTime scheduledAt,
  required MedicationLog? log,
  required DateTime now,
}) {
  if (log != null) return DoseStatus.realizado;
  if (scheduledAt.isAfter(now)) return DoseStatus.agendado;
  if (now.difference(scheduledAt) > _lateThreshold) return DoseStatus.atrasado;
  return DoseStatus.pendente;
}

class AdherenceStats {
  const AdherenceStats({
    required this.expected,
    required this.confirmed,
  });

  final int expected;
  final int confirmed;

  double get percentage {
    if (expected == 0) return 0;
    return (confirmed / expected) * 100;
  }

  bool get hasData => expected > 0;
}

AdherenceStats computeWeeklyAdherence({
  required List<MedicationSchedule> schedules,
  required List<MedicationLog> logs,
  required DateTime now,
}) {
  final today = DateTime(now.year, now.month, now.day);
  var expected = 0;
  var confirmed = 0;
  for (var i = 0; i < 7; i++) {
    final day = today.subtract(Duration(days: i));
    final doses = buildDosesForDay(
      day: day,
      schedules: schedules,
      logs: logs,
      now: now,
    );
    for (final dose in doses) {
      if (dose.scheduledAt.isAfter(now)) continue;
      expected++;
      if (dose.status == DoseStatus.realizado) confirmed++;
    }
  }
  return AdherenceStats(expected: expected, confirmed: confirmed);
}

MedicationSchedule? lowestStockSchedule(List<MedicationSchedule> schedules) {
  MedicationSchedule? best;
  int? bestDays;
  for (final s in schedules) {
    if (!s.tracksStock) continue;
    final d = s.daysOfStockRemaining;
    if (d == null) continue;
    if (bestDays == null || d < bestDays) {
      best = s;
      bestDays = d;
    }
  }
  return best;
}
