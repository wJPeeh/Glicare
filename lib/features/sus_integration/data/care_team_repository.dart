import 'dart:math';

import 'package:firebase_database/firebase_database.dart';

import 'care_team.dart';

class CareTeamRepository {
  CareTeamRepository(this._db);

  final FirebaseDatabase _db;

  // Alfabeto sem caracteres ambíguos (0/O, 1/I).
  static const _codeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  DatabaseReference _refFor(String uid) => _db.ref('users/$uid/care_team');

  DatabaseReference _codeRef(String code) => _db.ref('share_codes/$code');

  Stream<CareTeam> watch(String uid) {
    return _refFor(uid)
        .onValue
        .map((event) => CareTeam.fromSnapshot(event.snapshot.value));
  }

  Future<CareTeam> fetchOnce(String uid) async {
    final snap = await _refFor(uid).get();
    return CareTeam.fromSnapshot(snap.value);
  }

  Future<void> save({required String uid, required CareTeam team}) {
    return _refFor(uid).update(team.toJson());
  }

  Future<void> setShareEnabled({required String uid, required bool value}) {
    return _refFor(uid).update({'shareEnabled': value});
  }

  /// Garante que o paciente tenha um código de acesso curto. Se já existir,
  /// retorna o atual; senão gera, grava em `care_team/accessCode` e no índice
  /// reverso `share_codes/<code>` (para o painel do médico resolver).
  Future<String> ensureAccessCode(String uid) async {
    final existing = await fetchOnce(uid);
    if (existing.accessCode != null && existing.accessCode!.isNotEmpty) {
      return existing.accessCode!;
    }
    final code = await _generateUniqueCode();
    await _codeRef(code).set(uid);
    await _refFor(uid).update({'accessCode': code});
    return code;
  }

  /// Resolve um código de acesso para o uid do paciente (usado pelo painel).
  Future<String?> resolveCode(String code) async {
    final snap = await _codeRef(code.trim().toUpperCase()).get();
    final value = snap.value;
    return value is String && value.isNotEmpty ? value : null;
  }

  Future<String> _generateUniqueCode() async {
    final rnd = Random.secure();
    for (var attempt = 0; attempt < 8; attempt++) {
      final code = List.generate(
        6,
        (_) => _codeAlphabet[rnd.nextInt(_codeAlphabet.length)],
      ).join();
      final snap = await _codeRef(code).get();
      if (!snap.exists) return code;
    }
    // Fallback improvável: usa timestamp.
    return 'G${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}'
        .substring(0, 6);
  }
}
