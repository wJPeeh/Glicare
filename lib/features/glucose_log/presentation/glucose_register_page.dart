import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glicare_app_bar.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../auth/presentation/auth_providers.dart';
import 'glucose_providers.dart';

class GlucoseRegisterPage extends ConsumerStatefulWidget {
  const GlucoseRegisterPage({super.key});

  @override
  ConsumerState<GlucoseRegisterPage> createState() =>
      _GlucoseRegisterPageState();
}

class _GlucoseRegisterPageState extends ConsumerState<GlucoseRegisterPage> {
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _datetime = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int? get _parsedValue => int.tryParse(_valueController.text.trim());

  _GlucoseRange _rangeFor(int? value) {
    if (value == null || value <= 0) return _GlucoseRange.unknown;
    if (value < 70) return _GlucoseRange.hipo;
    if (value <= 140) return _GlucoseRange.normal;
    if (value <= 180) return _GlucoseRange.elevada;
    return _GlucoseRange.hiper;
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _datetime,
      firstDate: now.subtract(const Duration(days: 7)),
      lastDate: now.add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_datetime),
    );
    if (time == null || !mounted) return;
    setState(() {
      _datetime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _setNow() {
    setState(() => _datetime = DateTime.now());
  }

  Future<void> _submit() async {
    final value = _parsedValue;
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um valor de glicemia válido.')),
      );
      return;
    }
    if (value > 600) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Valor muito alto. Confirme se está em mg/dL.'),
        ),
      );
      return;
    }
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessão expirada. Faça login novamente.')),
      );
      return;
    }
    final notes = _notesController.text.trim();
    setState(() => _saving = true);
    try {
      await ref.read(glucoseRepositoryProvider).create(
            uid: user.uid,
            valueMgdl: value,
            measuredAt: _datetime,
            notes: notes.isEmpty ? null : notes,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Glicemia registrada: $value mg/dL.'),
          backgroundColor: AppColors.secondary,
        ),
      );
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.dashboard);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao salvar: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final range = _rangeFor(_parsedValue);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GlicareAppBar(title: 'Registrar Glicemia'),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: GradientButton(
            label: _saving ? 'Salvando...' : 'Salvar Medição',
            icon: Icons.check_circle,
            onPressed: _saving ? null : _submit,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionLabel('Valor medido'),
            const SizedBox(height: 12),
            _ValueCard(
              controller: _valueController,
              range: range,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            _RangeLegend(range: range),
            const SizedBox(height: 24),
            const _SectionLabel('Horário da medição'),
            const SizedBox(height: 12),
            _DateTimeCard(
              datetime: _datetime,
              onNow: _setNow,
              onPick: _pickDateTime,
            ),
            const SizedBox(height: 24),
            const _SectionLabel('Observações (opcional)'),
            const SizedBox(height: 12),
            _NotesField(controller: _notesController),
          ],
        ),
      ),
    );
  }
}

enum _GlucoseRange { unknown, hipo, normal, elevada, hiper }

extension _GlucoseRangeProps on _GlucoseRange {
  Color get color => switch (this) {
        _GlucoseRange.unknown => AppColors.outline,
        _GlucoseRange.hipo => AppColors.error,
        _GlucoseRange.normal => AppColors.secondary,
        _GlucoseRange.elevada => AppColors.tertiaryFixedDim,
        _GlucoseRange.hiper => AppColors.error,
      };

  String get label => switch (this) {
        _GlucoseRange.unknown => '—',
        _GlucoseRange.hipo => 'Hipoglicemia',
        _GlucoseRange.normal => 'Normal',
        _GlucoseRange.elevada => 'Elevada',
        _GlucoseRange.hiper => 'Hiperglicemia',
      };

  String get hint => switch (this) {
        _GlucoseRange.unknown => 'Digite seu valor de glicemia em mg/dL',
        _GlucoseRange.hipo => 'Abaixo de 70 mg/dL — atenção à hipoglicemia',
        _GlucoseRange.normal => 'Entre 70 e 140 mg/dL — faixa esperada',
        _GlucoseRange.elevada => 'Entre 141 e 180 mg/dL — levemente elevada',
        _GlucoseRange.hiper => 'Acima de 180 mg/dL — hiperglicemia',
      };
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurfaceVariant,
          letterSpacing: 1.6,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow(),
      ),
      child: child,
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.controller,
    required this.range,
    required this.onChanged,
  });

  final TextEditingController controller;
  final _GlucoseRange range;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final accent = range.color;
    return _Card(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          const Icon(Icons.bloodtype, color: AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IntrinsicWidth(
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  onChanged: onChanged,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: accent,
                    letterSpacing: -2,
                    height: 1,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText: '000',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: AppColors.outlineVariant.withValues(alpha: 0.5),
                      letterSpacing: -2,
                      height: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'mg/dL',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              range.label.toUpperCase(),
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: accent,
                letterSpacing: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeLegend extends StatelessWidget {
  const _RangeLegend({required this.range});
  final _GlucoseRange range;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        range.hint,
        style: GoogleFonts.manrope(
          fontSize: 12,
          color: AppColors.onSurfaceVariant,
          height: 1.4,
        ),
      ),
    );
  }
}

class _DateTimeCard extends StatelessWidget {
  const _DateTimeCard({
    required this.datetime,
    required this.onNow,
    required this.onPick,
  });

  final DateTime datetime;
  final VoidCallback onNow;
  final VoidCallback onPick;

  bool _isWithinLastMinute(DateTime dt) =>
      DateTime.now().difference(dt).inSeconds.abs() < 60;

  @override
  Widget build(BuildContext context) {
    final isNow = _isWithinLastMinute(datetime);
    final formatter = DateFormat('dd/MM/yyyy • HH:mm');
    return _Card(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.schedule, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isNow ? 'Agora' : formatter.format(datetime),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isNow
                      ? formatter.format(datetime)
                      : 'Toque em "Agora" para usar o horário atual',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (!isNow)
            TextButton(
              onPressed: onNow,
              child: Text(
                'Agora',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          IconButton(
            onPressed: onPick,
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _NotesField extends StatelessWidget {
  const _NotesField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        maxLines: 3,
        minLines: 1,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Antes do almoço, em jejum, pós-exercício...',
          hintStyle: GoogleFonts.manrope(color: AppColors.outline),
          prefixIcon: const Icon(Icons.notes, color: AppColors.primary),
        ),
      ),
    );
  }
}
