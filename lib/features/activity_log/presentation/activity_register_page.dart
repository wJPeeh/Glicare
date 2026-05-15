import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glicare_app_bar.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/activity_log.dart';
import 'activity_providers.dart';

class _TypeStyle {
  const _TypeStyle(this.icon, this.color);
  final IconData icon;
  final Color color;
}

const Map<ActivityType, _TypeStyle> _typeStyles = {
  ActivityType.caminhada:
      _TypeStyle(Icons.directions_walk, AppColors.secondary),
  ActivityType.corrida: _TypeStyle(Icons.directions_run, AppColors.primary),
  ActivityType.musculacao:
      _TypeStyle(Icons.fitness_center, AppColors.tertiaryFixedDim),
  ActivityType.bike:
      _TypeStyle(Icons.directions_bike, AppColors.secondaryDim),
  ActivityType.outro: _TypeStyle(Icons.sports, AppColors.outline),
};

class ActivityRegisterPage extends ConsumerStatefulWidget {
  const ActivityRegisterPage({super.key});

  @override
  ConsumerState<ActivityRegisterPage> createState() =>
      _ActivityRegisterPageState();
}

class _ActivityRegisterPageState extends ConsumerState<ActivityRegisterPage> {
  ActivityType? _selectedType;
  int _duration = 30;
  DateTime _datetime = DateTime.now();
  bool _saving = false;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _incrementDuration() {
    setState(() => _duration = (_duration + 5).clamp(5, 480));
  }

  void _decrementDuration() {
    setState(() => _duration = (_duration - 5).clamp(5, 480));
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
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o tipo de atividade.')),
      );
      return;
    }
    if (_duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe uma duração válida.')),
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
    final type = _selectedType!;
    setState(() => _saving = true);
    try {
      await ref.read(activityLogRepositoryProvider).create(
            uid: user.uid,
            type: type,
            durationMinutes: _duration,
            performedAt: _datetime,
            notes: notes.isEmpty ? null : notes,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${type.label} registrada: $_duration min.'),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GlicareAppBar(title: 'Registrar Atividade'),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: GradientButton(
            label: _saving ? 'Salvando...' : 'Salvar Atividade',
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
            const _SectionLabel('Tipo de atividade'),
            const SizedBox(height: 12),
            _TypeGrid(
              selected: _selectedType,
              onSelect: (t) => setState(() => _selectedType = t),
            ),
            const SizedBox(height: 24),
            const _SectionLabel('Duração'),
            const SizedBox(height: 12),
            _DurationCard(
              duration: _duration,
              onIncrement: _incrementDuration,
              onDecrement: _decrementDuration,
            ),
            const SizedBox(height: 24),
            const _SectionLabel('Horário'),
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

class _TypeGrid extends StatelessWidget {
  const _TypeGrid({required this.selected, required this.onSelect});
  final ActivityType? selected;
  final ValueChanged<ActivityType> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.95,
      children: ActivityType.values.map((type) {
        final style = _typeStyles[type]!;
        final isSelected = selected == type;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onSelect(type),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? [
                          style.color.withValues(alpha: 0.28),
                          style.color.withValues(alpha: 0.14),
                        ]
                      : [
                          style.color.withValues(alpha: 0.1),
                          style.color.withValues(alpha: 0.04),
                        ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? style.color.withValues(alpha: 0.6)
                      : style.color.withValues(alpha: 0.1),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      shape: BoxShape.circle,
                      boxShadow:
                          AppColors.softShadow(y: 4, blur: 10, opacity: 0.05),
                    ),
                    child: Icon(style.icon, color: style.color, size: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    type.label,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      color: style.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DurationCard extends StatelessWidget {
  const _DurationCard({
    required this.duration,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int duration;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          _StepperButton(icon: Icons.remove, onTap: onDecrement),
          Expanded(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$duration',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: -2,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'min',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurfaceVariant
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'minutos',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          _StepperButton(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.primary, size: 22),
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
          hintText: 'Como foi a atividade? Algo notado?',
          hintStyle: GoogleFonts.manrope(color: AppColors.outline),
          prefixIcon: const Icon(Icons.notes, color: AppColors.primary),
        ),
      ),
    );
  }
}
