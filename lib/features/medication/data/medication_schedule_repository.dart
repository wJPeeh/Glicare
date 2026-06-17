import 'package:firebase_database/firebase_database.dart';

import 'medication_schedule.dart';

class MedicationScheduleRepository {
  MedicationScheduleRepository(this._db);

  final FirebaseDatabase _db;

  DatabaseReference _schedulesFor(String uid) =>
      _db.ref('users/$uid/medication_schedules');

  Future<String> create({
    required String uid,
    required String name,
    required String dosage,
    required List<int> daysOfWeek,
    required List<int> timesOfDay,
    required bool pushEnabled,
    int? pillsPerDose,
    int? pillsRemaining,
  }) async {
    final now = DateTime.now();
    final ref = _schedulesFor(uid).push();
    await ref.set({
      'name': name,
      'dosage': dosage,
      'daysOfWeek': daysOfWeek,
      'timesOfDay': timesOfDay,
      'pushEnabled': pushEnabled,
      'active': true,
      'pillsPerDose': pillsPerDose,
      'pillsRemaining': pillsRemaining,
      'createdAt': now.millisecondsSinceEpoch,
    });
    return ref.key!;
  }

  Future<void> update({
    required String uid,
    required MedicationSchedule schedule,
  }) {
    return _schedulesFor(uid).child(schedule.id).update(schedule.toJson());
  }

  Future<void> decrementStock({
    required String uid,
    required String scheduleId,
    required int pills,
  }) async {
    final ref = _schedulesFor(uid).child(scheduleId).child('pillsRemaining');
    await ref.runTransaction((value) {
      if (value is! num) return Transaction.abort();
      final next = (value.toInt() - pills).clamp(0, 1 << 30);
      return Transaction.success(next);
    });
  }

  Stream<List<MedicationSchedule>> watchAll(String uid) {
    return _schedulesFor(uid).onValue.map((event) {
      final raw = event.snapshot.value;
      if (raw is! Map) return <MedicationSchedule>[];
      final schedules = raw.entries
          .map((e) =>
              MedicationSchedule.fromSnapshot(e.key as String, e.value))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return schedules;
    });
  }

  Future<void> delete({required String uid, required String scheduleId}) {
    return _schedulesFor(uid).child(scheduleId).remove();
  }
}
