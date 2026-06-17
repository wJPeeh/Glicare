import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glicare_app_bar.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/medication_schedule.dart';
import 'medication_log_providers.dart';

class _QuickMed {
  const _QuickMed(this.name, this.dosage, this.icon, this.color);
  final String name;
  final String dosage;
  final IconData icon;
  final Color color;
}

const List<_QuickMed> _quickMeds = [
  _QuickMed('Metformina', '500mg', Icons.medication, AppColors.primary),
  _QuickMed('Glifage XR', '500mg', Icons.medication_outlined, AppColors.secondary),
  _QuickMed('Insulina', '10UI', Icons.colorize, AppColors.tertiaryFixedDim),
  _QuickMed('Sinvastatina', '20mg', Icons.medication, AppColors.error),
];

class MedicationRegisterPage extends ConsumerStatefulWidget {
  const MedicationRegisterPage({super.key});

  @override
  ConsumerState<MedicationRegisterPage> createState() =>
      _MedicationRegisterPageState();
}

class _MedicationRegisterPageState
    extends ConsumerState<MedicationRegisterPage> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _pillsRemainingController = TextEditingController();
  final _pillsPerDoseController = TextEditingController();

  final Set<int> _days = {1, 2, 3, 4, 5, 6, 7};
  final List<int> _times = <int>[8 * 60];
  bool _pushEnabled = true;
  bool _trackStock = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _pillsRemainingController.dispose();
    _pillsPerDoseController.dispose();
    super.dispose();
  }

  void _applyQuickMed(_QuickMed med) {
    setState(() {
      _nameController.text = med.name;
      _dosageController.text = med.dosage;
    });
  }

  void _toggleDay(int weekday) {
    setState(() {
      if (_days.contains(weekday)) {
        if (_days.length > 1) _days.remove(weekday);
      } else {
        _days.add(weekday);
      }
    });
  }

  void _selectAllDays() {
    setState(() {
      _days
        ..clear()
        ..addAll(const [1, 2, 3, 4, 5, 6, 7]);
    });
  }

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked == null) return;
    final minutes = picked.hour * 60 + picked.minute;
    setState(() {
      if (!_times.contains(minutes)) {
        _times
          ..add(minutes)
          ..sort();
      }
    });
  }

  Future<void> _editTime(int index) async {
    final current = _times[index];
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked == null) return;
    final minutes = picked.hour * 60 + picked.minute;
    setState(() {
      _times[index] = minutes;
      _times.sort();
      final unique = _times.toSet().toList()..sort();
      _times
        ..clear()
        ..addAll(unique);
    });
  }

  void _removeTime(int index) {
    if (_times.length == 1) return;
    setState(() => _times.removeAt(index));
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome da medicação.')),
      );
      return;
    }
    if (_times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione ao menos um horário.')),
      );
      return;
    }
    if (_days.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione ao menos um dia.')),
      );
      return;
    }

    int? pillsRemaining;
    int? pillsPerDose;
    if (_trackStock) {
      pillsRemaining = int.tryParse(_pillsRemainingController.text.trim());
      pillsPerDose = int.tryParse(_pillsPerDoseController.text.trim());
      if (pillsRemaining == null || pillsRemaining <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informe a quantidade em estoque.')),
        );
        return;
      }
      if (pillsPerDose == null || pillsPerDose <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informe quantos comprimidos por dose.')),
        );
        return;
      }
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessão expirada. Faça login novamente.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final notifications = ref.read(medicationNotificationsProvider);
      if (_pushEnabled) {
        await notifications.requestPermissions();
      }
      final repo = ref.read(medicationScheduleRepositoryProvider);
      final daysSorted = _days.toList()..sort();
      final timesSorted = List<int>.from(_times)..sort();
      final scheduleId = await repo.create(
        uid: user.uid,
        name: name,
        dosage: _dosageController.text.trim(),
        daysOfWeek: daysSorted,
        timesOfDay: timesSorted,
        pushEnabled: _pushEnabled,
        pillsRemaining: pillsRemaining,
        pillsPerDose: pillsPerDose,
      );

      final schedule = MedicationSchedule(
        id: scheduleId,
        name: name,
        dosage: _dosageController.text.trim(),
        daysOfWeek: daysSorted,
        timesOfDay: timesSorted,
        pushEnabled: _pushEnabled,
        active: true,
        pillsPerDose: pillsPerDose,
        pillsRemaining: pillsRemaining,
        createdAt: DateTime.now(),
      );
      await notifications.syncSchedule(schedule);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name agendada.'),
          backgroundColor: AppColors.secondary,
        ),
      );
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.medicationHistory);
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
      appBar: GlicareAppBar(
        title: 'Nova Medicação',
        action: IconButton(
          tooltip: 'Histórico',
          onPressed: () => context.push(AppRoutes.medicationHistory),
          icon: const Icon(Icons.history, color: AppColors.primary),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: GradientButton(
            label: _saving ? 'Salvando...' : 'Confirmar Registro',
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
            const _SectionLabel('Frequentes'),
            const SizedBox(height: 12),
            _QuickMedsGrid(
              currentName: _nameController.text.trim(),
              onSelect: _applyQuickMed,
            ),
            const SizedBox(height: 24),
            const _SectionLabel('Medicação'),
            const SizedBox(height: 12),
            _NameField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            const _SectionLabel('Dosagem'),
            const SizedBox(height: 12),
            _DosageField(controller: _dosageController),
            const SizedBox(height: 24),
            const _SectionLabel('Dias da semana'),
            const SizedBox(height: 12),
            _WeekdaysCard(
              selected: _days,
              onToggle: _toggleDay,
              onSelectAll: _selectAllDays,
            ),
            const SizedBox(height: 24),
            const _SectionLabel('Horários'),
            const SizedBox(height: 12),
            _TimesCard(
              times: _times,
              onAdd: _addTime,
              onEdit: _editTime,
              onRemove: _removeTime,
            ),
            const SizedBox(height: 24),
            const _SectionLabel('Lembrete'),
            const SizedBox(height: 12),
            _PushCard(
              enabled: _pushEnabled,
              onChanged: (v) => setState(() => _pushEnabled = v),
            ),
            const SizedBox(height: 24),
            const _SectionLabel('Estoque (opcional)'),
            const SizedBox(height: 12),
            _StockCard(
              enabled: _trackStock,
              pillsRemainingController: _pillsRemainingController,
              pillsPerDoseController: _pillsPerDoseController,
              onChanged: (v) => setState(() => _trackStock = v),
            ),
            const SizedBox(height: 24),
            const _Tip(),
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

class _QuickMedsGrid extends StatelessWidget {
  const _QuickMedsGrid({required this.currentName, required this.onSelect});

  final String currentName;
  final ValueChanged<_QuickMed> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.6,
      children: _quickMeds.map((med) {
        final selected = currentName.toLowerCase() == med.name.toLowerCase();
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onSelect(med),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? med.color.withValues(alpha: 0.18)
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected
                      ? med.color.withValues(alpha: 0.6)
                      : Colors.transparent,
                  width: selected ? 2 : 1,
                ),
                boxShadow: selected
                    ? null
                    : AppColors.softShadow(y: 4, blur: 12, opacity: 0.04),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: med.color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(med.icon, color: med.color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          med.name,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          med.dosage,
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
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

class _NameField extends StatelessWidget {
  const _NameField({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.next,
        onChanged: onChanged,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Ex: Metformina',
          hintStyle: GoogleFonts.manrope(color: AppColors.outline),
          prefixIcon: const Icon(Icons.medication, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _DosageField extends StatelessWidget {
  const _DosageField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.next,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Ex: 500mg, 10UI, 1 comprimido',
          hintStyle: GoogleFonts.manrope(color: AppColors.outline),
          prefixIcon: const Icon(Icons.straighten, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _WeekdaysCard extends StatelessWidget {
  const _WeekdaysCard({
    required this.selected,
    required this.onToggle,
    required this.onSelectAll,
  });

  final Set<int> selected;
  final ValueChanged<int> onToggle;
  final VoidCallback onSelectAll;

  @override
  Widget build(BuildContext context) {
    final allSelected = selected.length == 7;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  allSelected ? 'Todos os dias' : '${selected.length} dias',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              if (!allSelected)
                TextButton(
                  onPressed: onSelectAll,
                  child: Text(
                    'Todo dia',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var d = 1; d <= 7; d++)
                _DayChip(
                  label: weekdayShortLabels[d]!,
                  selected: selected.contains(d),
                  onTap: () => onToggle(d),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : AppColors.onSurfaceVariant,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimesCard extends StatelessWidget {
  const _TimesCard({
    required this.times,
    required this.onAdd,
    required this.onEdit,
    required this.onRemove,
  });

  final List<int> times;
  final VoidCallback onAdd;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < times.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == times.length - 1 ? 0 : 8),
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
                    child: InkWell(
                      onTap: () => onEdit(i),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          formatMinutes(times[i]),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (times.length > 1)
                    IconButton(
                      tooltip: 'Remover horário',
                      onPressed: () => onRemove(i),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, color: AppColors.primary),
              label: Text(
                'Adicionar horário',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PushCard extends StatelessWidget {
  const _PushCard({required this.enabled, required this.onChanged});
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_active,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notificação push',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Receber lembrete no horário de cada dose.',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _StockCard extends StatelessWidget {
  const _StockCard({
    required this.enabled,
    required this.pillsRemainingController,
    required this.pillsPerDoseController,
    required this.onChanged,
  });

  final bool enabled;
  final TextEditingController pillsRemainingController;
  final TextEditingController pillsPerDoseController;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    color: AppColors.tertiary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Controlar estoque',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      'Avisamos quando estiver acabando.',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: onChanged,
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _NumberField(
                    label: 'Comprimidos restantes',
                    hint: 'Ex: 60',
                    controller: pillsRemainingController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NumberField(
                    label: 'Por dose',
                    hint: 'Ex: 1',
                    controller: pillsPerDoseController,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.hint,
    required this.controller,
  });
  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.4,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            hintText: hint,
            hintStyle: GoogleFonts.manrope(color: AppColors.outline),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: AppColors.primary.withValues(alpha: 0.9),
                  height: 1.5,
                ),
                children: const [
                  TextSpan(
                      text:
                          'Manter a consistência no horário das medicações ajuda a estabilizar seus níveis glicêmicos em até '),
                  TextSpan(
                    text: '15%',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
