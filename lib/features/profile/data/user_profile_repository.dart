import 'package:firebase_database/firebase_database.dart';

import 'user_profile.dart';

class UserProfileRepository {
  UserProfileRepository(this._db);

  final FirebaseDatabase _db;

  DatabaseReference _profileFor(String uid) =>
      _db.ref('users/$uid/profile');

  Stream<UserProfile> watch(String uid) {
    return _profileFor(uid)
        .onValue
        .map((event) => UserProfile.fromSnapshot(event.snapshot.value));
  }

  Future<void> setPhone({required String uid, required String? phone}) {
    final trimmed = phone?.trim();
    return _profileFor(uid).update({
      'phone': (trimmed == null || trimmed.isEmpty) ? null : trimmed,
    });
  }

  Future<void> setCustomPhotoUrl({
    required String uid,
    required String? url,
  }) {
    return _profileFor(uid).update({
      'customPhotoUrl': (url == null || url.isEmpty) ? null : url,
    });
  }

  Future<void> setNotificationsOnboarded({
    required String uid,
    required bool value,
  }) {
    return _profileFor(uid).update({'notificationsOnboarded': value});
  }
}
