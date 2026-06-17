import 'package:firebase_database/firebase_database.dart';

import 'medication_log.dart';

class MedicationLogRepository {
  MedicationLogRepository(this._db);

  final FirebaseDatabase _db;

  DatabaseReference _logsFor(String uid) =>
      _db.ref('users/$uid/medication_logs');

  Future<String> create({
    required String uid,
    required String name,
    required DateTime takenAt,
    String? dosage,
    String? notes,
    String? scheduleId,
    int? expectedMinute,
  }) async {
    final now = DateTime.now();
    final ref = _logsFor(uid).push();
    await ref.set({
      'name': name,
      'dosage': dosage,
      'notes': notes,
      'scheduleId': scheduleId,
      'expectedMinute': expectedMinute,
      'takenAt': takenAt.millisecondsSinceEpoch,
      'createdAt': now.millisecondsSinceEpoch,
    });
    return ref.key!;
  }

  Stream<List<MedicationLog>> watchRecent(String uid, {int limit = 200}) {
    return _logsFor(uid)
        .orderByChild('takenAt')
        .limitToLast(limit)
        .onValue
        .map((event) {
      final raw = event.snapshot.value;
      if (raw is! Map) return <MedicationLog>[];
      final logs = raw.entries
          .map((e) => MedicationLog.fromSnapshot(e.key as String, e.value))
          .toList()
        ..sort((a, b) => b.takenAt.compareTo(a.takenAt));
      return logs;
    });
  }

  Future<void> delete({required String uid, required String logId}) {
    return _logsFor(uid).child(logId).remove();
  }
}
