import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../data/doctor_repository.dart';
import '../data/patient_data.dart';
import 'doctor_dashboard_page.dart';

class DoctorApp extends StatelessWidget {
  const DoctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glicare • Painel Clínico',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const DoctorGate(),
    );
  }
}

class DoctorGate extends StatefulWidget {
  const DoctorGate({super.key});

  @override
  State<DoctorGate> createState() => _DoctorGateState();
}

enum _Phase { booting, login, loading, loaded, error }

class _DoctorGateState extends State<DoctorGate> {
  final _repo = DoctorRepository(FirebaseDatabase.instance);
  final _codeController = TextEditingController();

  _Phase _phase = _Phase.booting;
  String? _error;
  PatientData? _patient;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      setState(() => _phase = _Phase.login);
    } catch (e) {
      setState(() {
        _phase = _Phase.error;
        _error =
            'Falha ao iniciar a sessão do painel. Verifique se o login anônimo está habilitado no Firebase.\n\n$e';
      });
    }
  }

  Future<void> _load() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _phase = _Phase.loading;
      _error = null;
    });
    try {
      final patient = await _repo.loadPatientByCode(code);
      setState(() {
        _patient = patient;
        _phase = _Phase.loaded;
      });
    } catch (e) {
      setState(() {
        _phase = _Phase.login;
        _error = e.toString();
      });
    }
  }

  Future<void> _reload() async {
    final current = _patient;
    if (current == null) return;
    try {
      final patient = await _repo.loadPatient(current.uid);
      if (mounted) setState(() => _patient = patient);
    } catch (_) {
      // Mantém os dados atuais em caso de falha de recarga.
    }
  }

  void _logout() {
    setState(() {
      _patient = null;
      _codeController.clear();
      _phase = _Phase.login;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.booting:
      case _Phase.loading:
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(child: CircularProgressIndicator()),
        );
      case _Phase.loaded:
        return DoctorDashboardPage(
          patient: _patient!,
          repo: _repo,
          onLogout: _logout,
          onRefresh: _reload,
        );
      case _Phase.error:
        return _ErrorScreen(message: _error ?? 'Erro desconhecido');
      case _Phase.login:
        return _LoginScreen(
          controller: _codeController,
          error: _error,
          onSubmit: _load,
        );
    }
  }
}

class _LoginScreen extends StatelessWidget {
  const _LoginScreen({
    required this.controller,
    required this.error,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final String? error;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.favorite,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Glicare',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Painel Clínico',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Acompanhe seu paciente',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Insira o código de acesso que o paciente compartilhou no app Glicare.',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: controller,
                  onSubmitted: (_) => onSubmit(),
                  textCapitalization: TextCapitalization.characters,
                  style: GoogleFonts.robotoMono(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: 4,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Código de acesso (6 dígitos)',
                    hintText: 'Ex.: 4F7K2P',
                    filled: true,
                    fillColor: AppColors.surfaceContainerLowest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            error!,
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    onPressed: onSubmit,
                    child: Text(
                      'Acessar painel',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off,
                    size: 48, color: AppColors.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
