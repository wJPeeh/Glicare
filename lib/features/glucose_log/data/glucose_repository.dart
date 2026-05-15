import 'package:firebase_database/firebase_database.dart';

import 'glucose_reading.dart';

class GlucoseRepository {
  GlucoseRepository(this._db);

  final FirebaseDatabase _db;

  DatabaseReference _readingsFor(String uid) =>
      _db.ref('users/$uid/glucose_readings');

  Future<String> create({
    required String uid,
    required int valueMgdl,
    required DateTime measuredAt,
    String? notes,
  }) async {
    final now = DateTime.now();
    final ref = _readingsFor(uid).push();
    await ref.set({
      'valueMgdl': valueMgdl,
      'notes': notes,
      'measuredAt': measuredAt.millisecondsSinceEpoch,
      'createdAt': now.millisecondsSinceEpoch,
    });
    return ref.key!;
  }

  Stream<List<GlucoseReading>> watchRecent(String uid, {int limit = 50}) {
    return _readingsFor(uid)
        .orderByChild('measuredAt')
        .limitToLast(limit)
        .onValue
        .map((event) {
      final raw = event.snapshot.value;
      if (raw is! Map) return <GlucoseReading>[];
      final readings = raw.entries
          .map((e) => GlucoseReading.fromSnapshot(e.key as String, e.value))
          .toList()
        ..sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
      return readings;
    });
  }

  Future<void> delete({required String uid, required String readingId}) {
    return _readingsFor(uid).child(readingId).remove();
  }
}
