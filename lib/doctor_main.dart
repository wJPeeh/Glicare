import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'features/doctor_panel/presentation/doctor_app.dart';
import 'firebase_options.dart';

/// Entry point do Painel Clínico (web) do médico.
///
/// Rodar com:
///   flutter run -d chrome -t lib/doctor_main.dart
/// Build:
///   flutter build web -t lib/doctor_main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('pt_BR');
  runApp(const DoctorApp());
}
