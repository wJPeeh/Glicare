import '../../glucose_log/data/glucose_reading.dart';
import '../../meal_log/data/meal_log.dart';
import '../../medication/data/medication_log.dart';
import '../../medication/data/medication_schedule.dart';
import '../../profile/data/user_profile.dart';
import '../../sus_integration/data/care_team.dart';

/// Visão agregada e somente-leitura dos dados de um paciente, usada pelo
/// painel web do médico.
class PatientData {
  const PatientData({
    required this.uid,
    required this.profile,
    required this.careTeam,
    required this.glucose,
    required this.schedules,
    required this.medicationLogs,
    required this.meals,
  });

  final String uid;
  final UserProfile profile;
  final CareTeam careTeam;
  final List<GlucoseReading> glucose;
  final List<MedicationSchedule> schedules;
  final List<MedicationLog> medicationLogs;
  final List<MealLog> meals;

  bool get shareGlucose => careTeam.shareEnabled && careTeam.shareGlucose;
  bool get shareMedication =>
      careTeam.shareEnabled && careTeam.shareMedication;
  bool get shareMeals => careTeam.shareEnabled && careTeam.shareMeals;
}
