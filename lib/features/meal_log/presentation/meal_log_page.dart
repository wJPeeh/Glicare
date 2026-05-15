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
import '../data/meal_log.dart';
import 'meal_log_providers.dart';

class _CategoryStyle {
  const _CategoryStyle(this.icon, this.color);
  final IconData icon;
  final Color color;
}

const Map<MealCategory, _CategoryStyle> _categoryStyles = {
  MealCategory.cafeManha: _CategoryStyle(Icons.coffee, AppColors.primary),
  MealCategory.almoco: _CategoryStyle(Icons.restaurant, AppColors.secondary),
  MealCategory.jantar:
      _CategoryStyle(Icons.dinner_dining, AppColors.tertiaryFixedDim),
  MealCategory.lanche: _CategoryStyle(Icons.cookie_outlined, AppColors.outline),
};

class MealLogPage extends ConsumerStatefulWidget {
  const MealLogPage({super.key});

  @override
  ConsumerState<MealLogPage> createState() => _MealLogPageState();
}

class _MealLogPageState extends ConsumerState<MealLogPage> {
  MealCategory? _selectedCategory;
  final List<String> _items = [];
  DateTime _datetime = DateTime.now();
  bool _saving = false;
  final _itemController = TextEditingController();
  final _glucoseController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categoryFromTime(_datetime);
  }

  @override
  void dispose() {
    _itemController.dispose();
    _glucoseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  MealCategory _categoryFromTime(DateTime dt) {
    final h = dt.hour;
    if (h < 11) return MealCategory.cafeManha;
    if (h < 15) return MealCategory.almoco;
    if (h < 18) return MealCategory.lanche;
    return MealCategory.jantar;
  }

  void _addItem() {
    final text = _itemController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _items.add(text);
      _itemController.clear();
    });
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
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
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a categoria da refeição.')),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um item.')),
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

    final glucoseText = _glucoseController.text.trim();
    final glucose = glucoseText.isEmpty ? null : int.tryParse(glucoseText);
    final notesText = _notesController.text.trim();
    final category = _selectedCategory!;

    setState(() => _saving = true);
    try {
      await ref.read(mealLogRepositoryProvider).create(
            uid: user.uid,
            category: category,
            items: List<String>.from(_items),
            eatenAt: _datetime,
            notes: notesText.isEmpty ? null : notesText,
            glucoseMgdl: glucose,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${category.label} registrado: ${_items.length} ${_items.length == 1 ? 'item' : 'itens'}.',
          ),
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
      appBar: GlicareAppBar(
        title: 'Registro de Refeição',
        action: IconButton(
          tooltip: 'Histórico',
          onPressed: () => context.push(AppRoutes.mealHistory),
          icon: const Icon(Icons.history, color: AppColors.primary),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: GradientButton(
            label: _saving ? 'Salvando...' : 'Salvar Refeição',
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
            const _SectionLabel('Categoria'),
            const SizedBox(height: 12),
            _CategoryGrid(
              selected: _selectedCategory,
              onSelect: (c) => setState(() => _selectedCategory = c),
            ),
            const SizedBox(height: 24),
            const _SectionLabel('Itens consumidos'),
            const SizedBox(height: 12),
            _ItemsCard(
              items: _items,
              controller: _itemController,
              onAdd: _addItem,
              onRemove: _removeItem,
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
            const _SectionLabel('Glicemia no momento (opcional)'),
            const SizedBox(height: 12),
            _GlucoseField(controller: _glucoseController),
            const SizedBox(height: 24),
            const _SectionLabel('Observações (opcional)'),
            const SizedBox(height: 12),
            _NotesField(controller: _notesController),
            const SizedBox(height: 24),
            const _GlicareTip(),
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

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.selected, required this.onSelect});
  final MealCategory? selected;
  final ValueChanged<MealCategory> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: MealCategory.values.map((cat) {
        final style = _categoryStyles[cat]!;
        final isSelected = selected == cat;
        return _CategoryTile(
          icon: style.icon,
          label: cat.label,
          color: style.color,
          selected: isSelected,
          onTap: () => onSelect(cat),
        );
      }).toList(),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: selected
                  ? [color.withValues(alpha: 0.28), color.withValues(alpha: 0.14)]
                  : [
                      color.withValues(alpha: 0.12),
                      color.withValues(alpha: 0.04),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.6)
                  : color.withValues(alpha: 0.1),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.softShadow(y: 4, blur: 12, opacity: 0.05),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({
    required this.items,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> items;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onAdd(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Ex: Arroz integral, Frango grelhado...',
                    hintStyle: GoogleFonts.manrope(color: AppColors.outline),
                    prefixIcon: const Icon(
                      Icons.restaurant_menu,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Nenhum item adicionado ainda.',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            )
          else ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < items.length; i++)
                  _ItemChip(label: items[i], onRemove: () => onRemove(i)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemChip extends StatelessWidget {
  const _ItemChip({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(99),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 16, color: AppColors.primary),
              ),
            ),
          ],
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

class _GlucoseField extends StatelessWidget {
  const _GlucoseField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Ex: 120',
          hintStyle: GoogleFonts.manrope(color: AppColors.outline),
          prefixIcon: const Icon(Icons.bloodtype, color: AppColors.primary),
          suffixText: 'mg/dL',
          suffixStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            color: AppColors.onSurfaceVariant,
          ),
        ),
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
          hintText: 'Como foi a refeição? Algum efeito notado?',
          hintStyle: GoogleFonts.manrope(color: AppColors.outline),
          prefixIcon: const Icon(Icons.notes, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _GlicareTip extends StatelessWidget {
  const _GlicareTip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.secondaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Opacity(
              opacity: 0.2,
              child: Icon(
                Icons.insights,
                size: 120,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DICA GLICARE',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 2.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Combine fibras com carboidratos\npara reduzir o índice glicêmico.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
