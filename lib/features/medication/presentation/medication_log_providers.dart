import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/database_providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/medication_adherence.dart';
import '../data/medication_log.dart';
import '../data/medication_log_repository.dart';
import '../data/medication_notifications.dart';
import '../data/medication_schedule.dart';
import '../data/medication_schedule_repository.dart';

final medicationLogRepositoryProvider =
    Provider<MedicationLogRepository>((ref) {
  return MedicationLogRepository(ref.watch(databaseProvider));
});

final medicationScheduleRepositoryProvider =
    Provider<MedicationScheduleRepository>((ref) {
  return MedicationScheduleRepository(ref.watch(databaseProvider));
});

final medicationNotificationsProvider = Provider<MedicationNotifications>(
  (ref) => MedicationNotifications.instance,
);

final recentMedicationLogsProvider =
    StreamProvider<List<MedicationLog>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(medicationLogRepositoryProvider).watchRecent(user.uid);
});

final medicationSchedulesProvider =
    StreamProvider<List<MedicationSchedule>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(medicationScheduleRepositoryProvider).watchAll(user.uid);
});

final todaysDosesProvider = Provider<AsyncValue<List<ScheduledDose>>>((ref) {
  final schedulesAsync = ref.watch(medicationSchedulesProvider);
  final logsAsync = ref.watch(recentMedicationLogsProvider);
  if (schedulesAsync.isLoading || logsAsync.isLoading) {
    return const AsyncValue.loading();
  }
  final schedules = schedulesAsync.asData?.value ?? const <MedicationSchedule>[];
  final logs = logsAsync.asData?.value ?? const <MedicationLog>[];
  final now = DateTime.now();
  return AsyncValue.data(
    buildDosesForDay(day: now, schedules: schedules, logs: logs, now: now),
  );
});

final weeklyAdherenceProvider = Provider<AsyncValue<AdherenceStats>>((ref) {
  final schedulesAsync = ref.watch(medicationSchedulesProvider);
  final logsAsync = ref.watch(recentMedicationLogsProvider);
  if (schedulesAsync.isLoading || logsAsync.isLoading) {
    return const AsyncValue.loading();
  }
  final schedules = schedulesAsync.asData?.value ?? const <MedicationSchedule>[];
  final logs = logsAsync.asData?.value ?? const <MedicationLog>[];
  return AsyncValue.data(computeWeeklyAdherence(
    schedules: schedules,
    logs: logs,
    now: DateTime.now(),
  ));
});

final lowestStockScheduleProvider =
    Provider<AsyncValue<MedicationSchedule?>>((ref) {
  final schedulesAsync = ref.watch(medicationSchedulesProvider);
  if (schedulesAsync.isLoading) return const AsyncValue.loading();
  final schedules = schedulesAsync.asData?.value ?? const <MedicationSchedule>[];
  return AsyncValue.data(lowestStockSchedule(schedules));
});
