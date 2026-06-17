import 'package:firebase_database/firebase_database.dart';

import 'care_note.dart';

class CareNotesRepository {
  CareNotesRepository(this._db);

  final FirebaseDatabase _db;

  DatabaseReference _ref(String uid) => _db.ref('users/$uid/care_notes');

  Stream<List<CareNote>> watch(String uid) {
    return _ref(uid).orderByChild('createdAt').onValue.map((event) {
      final raw = event.snapshot.value;
      if (raw is! Map) return <CareNote>[];
      return raw.entries
          .map((e) => CareNote.fromSnapshot(e.key as String, e.value))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  Future<void> add({
    required String uid,
    required String text,
    required CareNoteType type,
    required String authorName,
  }) {
    final note = CareNote(
      id: '',
      text: text.trim(),
      type: type,
      authorName: authorName,
      createdAt: DateTime.now(),
    );
    return _ref(uid).push().set(note.toJson());
  }

  Future<void> delete({required String uid, required String noteId}) {
    return _ref(uid).child(noteId).remove();
  }
}
