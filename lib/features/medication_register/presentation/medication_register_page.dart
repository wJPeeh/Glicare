import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glicare_app_bar.dart';
import '../../../core/widgets/gradient_button.dart';

class MedicationRegisterPage extends StatefulWidget {
  const MedicationRegisterPage({super.key});

  @override
  State<MedicationRegisterPage> createState() => _MedicationRegisterPageState();
}

class _MedicationRegisterPageState extends State<MedicationRegisterPage> {
  bool _push = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlicareAppBar(
        title: 'Registrar Medicação',
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
            label: 'Confirmar Registro',
            icon: Icons.check_circle,
            onPressed: () {},
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                hintText: 'Buscar medicação...',
                hintStyle: GoogleFonts.manrope(color: AppColors.outlineVariant),
                prefixIcon: const Icon(Icons.search, color: AppColors.outline),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Text(
                  'Medicações Frequentes',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  'Ver todos',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _MedCard(icon: Icons.medication, name: 'Metformina', sub: '500mg • Comprimido', tint: AppColors.primary),
                _MedCard(icon: Icons.medication_outlined, name: 'Glifage XR', sub: '500mg • Comprimido', tint: AppColors.secondary),
                _MedCard(icon: Icons.medication_liquid, name: 'Xarope Vit.', sub: '5ml • Líquido', tint: AppColors.tertiaryFixedDim),
              ],
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel('Dosagem'),
                  Row(
                    children: [
                      Expanded(
                        child: _SmallField(hint: 'Ex: 500'),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 110,
                        child: _SmallField(hint: 'mg'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Frequência'),
                  Row(
                    children: [
                      Expanded(
                        child: _FrequencyChip(label: 'Diário', icon: Icons.event_repeat, selected: true),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FrequencyChip(label: 'Personalizado', icon: Icons.tune, selected: false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Horário da Dose'),
                  _SmallField(
                    hint: '08:00',
                    suffix: const Icon(Icons.schedule, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Tipo de Lembrete'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Notificação Push',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _push,
                          onChanged: (v) => setState(() => _push = v),
                          activeTrackColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SmallField extends StatelessWidget {
  const _SmallField({required this.hint, this.suffix});
  final String hint;
  final Widget? suffix;
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        hintText: hint,
        hintStyle: GoogleFonts.manrope(color: AppColors.outline),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _FrequencyChip extends StatelessWidget {
  const _FrequencyChip({required this.label, required this.icon, required this.selected});
  final String label;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : AppColors.onSurfaceVariant, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedCard extends StatelessWidget {
  const _MedCard({required this.icon, required this.name, required this.sub, required this.tint});
  final IconData icon;
  final String name;
  final String sub;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: tint, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
