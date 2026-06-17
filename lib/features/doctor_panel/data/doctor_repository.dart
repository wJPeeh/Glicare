import 'package:firebase_database/firebase_database.dart';

import '../../care_notes/data/care_notes_repository.dart';
import '../../chat/data/chat_repository.dart';
import '../../glucose_log/data/glucose_reading.dart';
import '../../meal_log/data/meal_log.dart';
import '../../medication/data/medication_log.dart';
import '../../medication/data/medication_schedule.dart';
import '../../profile/data/user_profile.dart';
import '../../sus_integration/data/care_team.dart';
import 'patient_data.dart';

class PatientNotFoundException implements Exception {
  const PatientNotFoundException(this.code);
  final String code;
  @override
  String toString() =>
      'Nenhum paciente encontrado para o código informado.';
}

class SharingDisabledException implements Exception {
  @override
  String toString() =>
      'Este paciente desativou o compartilhamento de dados.';
}

class DoctorRepository {
  DoctorRepository(this._db)
      : careNotes = CareNotesRepository(_db),
        chat = ChatRepository(_db);

  final FirebaseDatabase _db;

  /// Repositórios compartilhados, reusados para escrita do médico.
  final CareNotesRepository careNotes;
  final ChatRepository chat;

  DatabaseReference _user(String uid) => _db.ref('users/$uid');

  /// Resolve o código curto de acesso para o uid do paciente.
  Future<String?> resolveCode(String code) async {
    final snap = await _db.ref('share_codes/${code.trim().toUpperCase()}').get();
    final value = snap.value;
    return value is String && value.isNotEmpty ? value : null;
  }

  /// Carrega o paciente a partir do código curto compartilhado no app.
  Future<PatientData> loadPatientByCode(String code) async {
    final trimmed = code.trim().toUpperCase();
    if (trimmed.isEmpty) throw PatientNotFoundException(code);
    final uid = await resolveCode(trimmed);
    if (uid == null) throw PatientNotFoundException(code);
    return loadPatient(uid);
  }

  /// Prescreve uma medicação que aparece na lista do paciente.
  Future<void> prescribeMedication({
    required String uid,
    required String name,
    required String dosage,
    required List<int> timesOfDay,
    required String prescriberName,
    List<int> daysOfWeek = const [1, 2, 3, 4, 5, 6, 7],
  }) {
    final schedule = MedicationSchedule(
      id: '',
      name: name.trim(),
      dosage: dosage.trim(),
      daysOfWeek: daysOfWeek,
      timesOfDay: timesOfDay,
      pushEnabled: true,
      // Prescrição entra inativa e pendente até o paciente confirmar no app.
      active: false,
      confirmed: false,
      createdAt: DateTime.now(),
      prescriberName: prescriberName,
    );
    return _user(uid).child('medication_schedules').push().set(schedule.toJson());
  }

  /// Carrega os dados do paciente pelo uid. Respeita as permissões de
  /// compartilhamento configuradas pelo paciente.
  Future<PatientData> loadPatient(String uid) async {
    if (uid.trim().isEmpty) throw PatientNotFoundException(uid);

    final careTeam = CareTeam.fromSnapshot(
      (await _safeGet(_user(uid).child('care_team'))),
    );
    final profileRaw = await _safeGet(_user(uid).child('profile'));

    // Sem nenhum vestígio do usuário → código inválido.
    if (!careTeam.isConfigured && profileRaw == null) {
      throw PatientNotFoundException(uid);
    }
    if (!careTeam.shareEnabled) {
      throw SharingDisabledException();
    }

    final profile = UserProfile.fromSnapshot(profileRaw);

    final glucose = careTeam.shareGlucose
        ? _parseGlucose(await _safeGet(_user(uid).child('glucose_readings')))
        : <GlucoseReading>[];

    final schedules = careTeam.shareMedication
        ? _parseSchedules(
            await _safeGet(_user(uid).child('medication_schedules')))
        : <MedicationSchedule>[];

    final medicationLogs = careTeam.shareMedication
        ? _parseMedLogs(await _safeGet(_user(uid).child('medication_logs')))
        : <MedicationLog>[];

    final meals = careTeam.shareMeals
        ? _parseMeals(await _safeGet(_user(uid).child('meal_logs')))
        : <MealLog>[];

    return PatientData(
      uid: uid,
      profile: profile,
      careTeam: careTeam,
      glucose: glucose,
      schedules: schedules,
      medicationLogs: medicationLogs,
      meals: meals,
    );
  }

  Future<Object?> _safeGet(DatabaseReference ref) async {
    try {
      final snap = await ref.get();
      return snap.value;
    } catch (_) {
      return null;
    }
  }

  List<GlucoseReading> _parseGlucose(Object? raw) {
    if (raw is! Map) return [];
    return raw.entries
        .map((e) => GlucoseReading.fromSnapshot(e.key as String, e.value))
        .toList()
      ..sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
  }

  List<MedicationSchedule> _parseSchedules(Object? raw) {
    if (raw is! Map) return [];
    return raw.entries
        .map((e) => MedicationSchedule.fromSnapshot(e.key as String, e.value))
        .toList();
  }

  List<MedicationLog> _parseMedLogs(Object? raw) {
    if (raw is! Map) return [];
    return raw.entries
        .map((e) => MedicationLog.fromSnapshot(e.key as String, e.value))
        .toList()
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt));
  }

  List<MealLog> _parseMeals(Object? raw) {
    if (raw is! Map) return [];
    return raw.entries
        .map((e) => MealLog.fromSnapshot(e.key as String, e.value))
        .toList()
      ..sort((a, b) => b.eatenAt.compareTo(a.eatenAt));
  }
}
