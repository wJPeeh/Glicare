import 'package:firebase_database/firebase_database.dart';

import 'activity_log.dart';

class ActivityLogRepository {
  ActivityLogRepository(this._db);

  final FirebaseDatabase _db;

  DatabaseReference _logsFor(String uid) =>
      _db.ref('users/$uid/activity_logs');

  Future<String> create({
    required String uid,
    required ActivityType type,
    required int durationMinutes,
    required DateTime performedAt,
    String? notes,
  }) async {
    final now = DateTime.now();
    final ref = _logsFor(uid).push();
    await ref.set({
      'type': type.name,
      'durationMinutes': durationMinutes,
      'notes': notes,
      'performedAt': performedAt.millisecondsSinceEpoch,
      'createdAt': now.millisecondsSinceEpoch,
    });
    return ref.key!;
  }

  Stream<List<ActivityLog>> watchRecent(String uid, {int limit = 50}) {
    return _logsFor(uid)
        .orderByChild('performedAt')
        .limitToLast(limit)
        .onValue
        .map((event) {
      final raw = event.snapshot.value;
      if (raw is! Map) return <ActivityLog>[];
      final logs = raw.entries
          .map((e) => ActivityLog.fromSnapshot(e.key as String, e.value))
          .toList()
        ..sort((a, b) => b.performedAt.compareTo(a.performedAt));
      return logs;
    });
  }

  Future<void> delete({required String uid, required String logId}) {
    return _logsFor(uid).child(logId).remove();
  }
}
