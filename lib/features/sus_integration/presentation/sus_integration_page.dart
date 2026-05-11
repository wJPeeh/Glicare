import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../core/widgets/glicare_app_bar.dart';

class SusIntegrationPage extends StatefulWidget {
  const SusIntegrationPage({super.key});

  @override
  State<SusIntegrationPage> createState() => _SusIntegrationPageState();
}

class _SusIntegrationPageState extends State<SusIntegrationPage> {
  bool _share = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlicareAppBar(title: 'Minha Equipe'),
      bottomNavigationBar: const GlicareBottomNav(activeIndex: 4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(36),
                boxShadow: AppColors.softShadow(),
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    color: AppColors.secondary,
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'CONECTADO AO SUS',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'SINCRONIZADO HÁ 5MIN',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.85),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'UBS Santa Cecília',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.onSurface,
                                      letterSpacing: -0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rede Municipal de Saúde • São Paulo',
                                    style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.account_balance, color: AppColors.secondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _SusInfoBox(label: 'CARTÃO SUS', value: '700 4056\n9912 0004', valueColor: AppColors.primary)),
                            const SizedBox(width: 12),
                            Expanded(child: _SusInfoBox(label: 'VÍNCULO', value: 'Ativo •\nPermanente')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Text(
                  'Compartilhamento de dados',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _share,
                  onChanged: (v) => setState(() => _share = v),
                  activeTrackColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(36),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SUA EQUIPE PODE VER:',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PermissionItem(icon: Icons.bloodtype, label: 'Histórico de Glicemia', tint: AppColors.primary),
                  const SizedBox(height: 8),
                  _PermissionItem(icon: Icons.medication, label: 'Uso de Medicamentos', tint: AppColors.secondary),
                  const SizedBox(height: 8),
                  _PermissionItem(icon: Icons.restaurant_menu, label: 'Registro Alimentar', tint: AppColors.tertiary),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Médico Responsável',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(36),
                boxShadow: AppColors.softShadow(opacity: 0.04),
                border: Border.all(color: Colors.white),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHighest,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.background, width: 4),
                              boxShadow: AppColors.softShadow(opacity: 0.1),
                            ),
                            child: const Icon(Icons.person, color: AppColors.onSurfaceVariant, size: 36),
                          ),
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.verified, color: Colors.white, size: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dra. Ana Silva',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onSurface,
                                letterSpacing: -0.4,
                              ),
                            ),
                            Text(
                              'Endocrinologista • CRM 123456',
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: AppColors.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  'UBS Santa Cecília • Sala 14',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: Text(
                        'Enviar mensagem',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.calendar_month, size: 18),
                      label: Text(
                        'Agendar consulta',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                      ),
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

class _SusInfoBox extends StatelessWidget {
  const _SusInfoBox({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.onSurface,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  const _PermissionItem({required this.icon, required this.label, required this.tint});
  final IconData icon;
  final String label;
  final Color tint;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: tint, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ),
          const Icon(Icons.check_circle, color: AppColors.secondary, size: 20),
        ],
      ),
    );
  }
}
