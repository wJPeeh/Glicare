import 'package:firebase_database/firebase_database.dart';

import 'meal_log.dart';

class MealLogRepository {
  MealLogRepository(this._db);

  final FirebaseDatabase _db;

  DatabaseReference _logsFor(String uid) => _db.ref('users/$uid/meal_logs');

  Future<String> create({
    required String uid,
    required MealCategory category,
    required List<String> items,
    required DateTime eatenAt,
    String? notes,
    int? glucoseMgdl,
  }) async {
    final now = DateTime.now();
    final ref = _logsFor(uid).push();
    await ref.set({
      'category': category.name,
      'items': items,
      'notes': notes,
      'glucoseMgdl': glucoseMgdl,
      'eatenAt': eatenAt.millisecondsSinceEpoch,
      'createdAt': now.millisecondsSinceEpoch,
    });
    return ref.key!;
  }

  Stream<List<MealLog>> watchRecent(String uid, {int limit = 50}) {
    return _logsFor(uid)
        .orderByChild('eatenAt')
        .limitToLast(limit)
        .onValue
        .map((event) {
      final raw = event.snapshot.value;
      if (raw is! Map) return <MealLog>[];
      final logs = raw.entries
          .map((e) => MealLog.fromSnapshot(e.key as String, e.value))
          .toList()
        ..sort((a, b) => b.eatenAt.compareTo(a.eatenAt));
      return logs;
    });
  }

  Future<void> delete({required String uid, required String logId}) {
    return _logsFor(uid).child(logId).remove();
  }
}
