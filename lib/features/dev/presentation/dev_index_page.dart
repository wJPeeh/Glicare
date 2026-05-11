import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';

class DevIndexPage extends StatelessWidget {
  const DevIndexPage({super.key});

  static const _items = <(String, String, IconData, Color)>[
    ('Welcome', AppRoutes.welcome, Icons.waving_hand, AppColors.primary),
    ('Login (Entrar)', AppRoutes.login, Icons.login, AppColors.primary),
    ('Signup (Criar Conta)', AppRoutes.signup, Icons.person_add, AppColors.primary),
    ('Dashboard', AppRoutes.dashboard, Icons.dashboard, AppColors.primary),
    ('Registrar Medicação', AppRoutes.medicationRegister, Icons.medication, AppColors.error),
    ('Histórico de Remédios', AppRoutes.medicationHistory, Icons.history, AppColors.error),
    ('Registro Alimentação', AppRoutes.mealLog, Icons.restaurant, AppColors.secondary),
    ('Impacto da Refeição', AppRoutes.mealImpact, Icons.analytics, AppColors.secondary),
    ('Gráfico de Evolução', AppRoutes.evolutionCharts, Icons.show_chart, AppColors.tertiaryFixedDim),
    ('Alertas Inteligentes', AppRoutes.smartAlerts, Icons.notifications_active, AppColors.tertiaryFixedDim),
    ('Equipe SUS', AppRoutes.susIntegration, Icons.account_balance, AppColors.secondary),
    ('Termos de Uso', AppRoutes.terms, Icons.description, AppColors.outline),
    ('Política de Privacidade', AppRoutes.privacy, Icons.shield, AppColors.outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Glicare • Dev Index',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final (label, route, icon, color) = _items[i];
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppColors.softShadow(opacity: 0.04, y: 4, blur: 12),
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onTap: () => context.go(route),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              title: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              subtitle: Text(
                route,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.outline),
            ),
          );
        },
      ),
    );
  }
}
