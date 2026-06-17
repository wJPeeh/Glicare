import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../care_notes/data/care_note.dart';
import '../data/doctor_repository.dart';

class DoctorActionsBar extends StatelessWidget {
  const DoctorActionsBar({
    super.key,
    required this.onPrescribe,
    required this.onAddNote,
  });

  final VoidCallback onPrescribe;
  final VoidCallback onAddNote;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.secondary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: onPrescribe,
          icon: const Icon(Icons.medication, size: 18),
          label: Text(
            'Prescrever medicamento',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          ),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3), width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: onAddNote,
          icon: const Icon(Icons.lightbulb_outline, size: 18),
          label: Text(
            'Nova orientação',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

Future<void> showPrescribeDialog(
  BuildContext context, {
  required DoctorRepository repo,
  required String uid,
  required String doctorName,
  required Future<void> Function() onDone,
}) async {
  await showDialog<void>(
    context: context,
    builder: (_) => _PrescribeDialog(
      repo: repo,
      uid: uid,
      doctorName: doctorName,
      onDone: onDone,
    ),
  );
}

Future<void> showCareNoteDialog(
  BuildContext context, {
  required DoctorRepository repo,
  required String uid,
  required String doctorName,
  required Future<void> Function() onDone,
}) async {
  await showDialog<void>(
    context: context,
    builder: (_) => _CareNoteDialog(
      repo: repo,
      uid: uid,
      doctorName: doctorName,
      onDone: onDone,
    ),
  );
}

class _PrescribeDialog extends StatefulWidget {
  const _PrescribeDialog({
    required this.repo,
    required this.uid,
    required this.doctorName,
    required this.onDone,
  });

  final DoctorRepository repo;
  final String uid;
  final String doctorName;
  final Future<void> Function() onDone;

  @override
  State<_PrescribeDialog> createState() => _PrescribeDialogState();
}

class _PrescribeDialogState extends State<_PrescribeDialog> {
  final _name = TextEditingController();
  final _dosage = TextEditingController();
  final _times = TextEditingController(text: '08:00');
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _dosage.dispose();
    _times.dispose();
    super.dispose();
  }

  /// Converte "08:00, 20:00" em minutos do dia [480, 1200].
  List<int> _parseTimes(String raw) {
    final result = <int>[];
    for (final part in raw.split(RegExp(r'[,;]'))) {
      final t = part.trim();
      final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(t);
      if (m == null) continue;
      final h = int.parse(m.group(1)!);
      final min = int.parse(m.group(2)!);
      if (h < 24 && min < 60) result.add(h * 60 + min);
    }
    return result..sort();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final times = _parseTimes(_times.text);
    if (name.isEmpty) {
      setState(() => _error = 'Informe o nome do medicamento.');
      return;
    }
    if (times.isEmpty) {
      setState(() => _error = 'Informe ao menos um horário (ex.: 08:00).');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.repo.prescribeMedication(
        uid: widget.uid,
        name: name,
        dosage: _dosage.text.trim(),
        timesOfDay: times,
        prescriberName: widget.doctorName,
      );
      await widget.onDone();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Prescrição enviada ao paciente: $name'),
          backgroundColor: AppColors.secondary,
        ),
      );
    } catch (e) {
      setState(() {
        _saving = false;
        _error = 'Falha ao prescrever: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        'Prescrever medicamento',
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogField(controller: _name, label: 'Medicamento'),
            _DialogField(
                controller: _dosage, label: 'Dosagem (ex.: 850mg)'),
            _DialogField(
              controller: _times,
              label: 'Horários (ex.: 08:00, 20:00)',
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: GoogleFonts.manrope(
                    color: AppColors.error, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.secondary),
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Prescrever'),
        ),
      ],
    );
  }
}

class _CareNoteDialog extends StatefulWidget {
  const _CareNoteDialog({
    required this.repo,
    required this.uid,
    required this.doctorName,
    required this.onDone,
  });

  final DoctorRepository repo;
  final String uid;
  final String doctorName;
  final Future<void> Function() onDone;

  @override
  State<_CareNoteDialog> createState() => _CareNoteDialogState();
}

class _CareNoteDialogState extends State<_CareNoteDialog> {
  final _text = TextEditingController();
  CareNoteType _type = CareNoteType.dica;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _text.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Escreva a orientação.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.repo.careNotes.add(
        uid: widget.uid,
        text: text,
        type: _type,
        authorName: widget.doctorName,
      );
      await widget.onDone();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Orientação enviada ao paciente.'),
          backgroundColor: AppColors.secondary,
        ),
      );
    } catch (e) {
      setState(() {
        _saving = false;
        _error = 'Falha ao enviar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        'Nova orientação',
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<CareNoteType>(
              segments: const [
                ButtonSegment(
                  value: CareNoteType.dica,
                  label: Text('Dica'),
                  icon: Icon(Icons.lightbulb_outline),
                ),
                ButtonSegment(
                  value: CareNoteType.cuidado,
                  label: Text('Cuidado'),
                  icon: Icon(Icons.health_and_safety_outlined),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _text,
              minLines: 3,
              maxLines: 6,
              style: GoogleFonts.manrope(),
              decoration: InputDecoration(
                hintText: 'Escreva a orientação para o paciente…',
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: GoogleFonts.manrope(
                    color: AppColors.error, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Enviar'),
        ),
      ],
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({required this.controller, required this.label});
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}
