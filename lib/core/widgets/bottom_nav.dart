import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../router/app_router.dart';
import '../theme/app_colors.dart';

Future<void> showRegisterActionSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => const _RegisterActionSheet(),
  );
}

class _RegisterActionSheet extends StatelessWidget {
  const _RegisterActionSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppColors.softShadow(y: 24, blur: 48, opacity: 0.18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
              child: Row(
                children: [
                  Text(
                    'Registrar',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            _RegisterOption(
              icon: Icons.bloodtype,
              tint: AppColors.primary,
              title: 'Glicemia',
              subtitle: 'Medir e registrar mg/dL',
              onTap: () {
                Navigator.of(context).pop();
                GoRouter.of(context).go(AppRoutes.glucoseRegister);
              },
            ),
            const SizedBox(height: 8),
            _RegisterOption(
              icon: Icons.restaurant,
              tint: AppColors.secondary,
              title: 'Refeição',
              subtitle: 'Logar o que comeu',
              onTap: () {
                Navigator.of(context).pop();
                GoRouter.of(context).go(AppRoutes.mealLog);
              },
            ),
            const SizedBox(height: 8),
            _RegisterOption(
              icon: Icons.medication,
              tint: AppColors.error,
              title: 'Medicamento',
              subtitle: 'Registrar uma dose tomada',
              onTap: () {
                Navigator.of(context).pop();
                GoRouter.of(context).go(AppRoutes.medicationRegister);
              },
            ),
            const SizedBox(height: 8),
            _RegisterOption(
              icon: Icons.fitness_center,
              tint: AppColors.tertiaryFixedDim,
              title: 'Atividade Física',
              subtitle: 'Caminhada, corrida, treino…',
              onTap: () {
                Navigator.of(context).pop();
                GoRouter.of(context).go(AppRoutes.activityRegister);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterOption extends StatelessWidget {
  const _RegisterOption({
    required this.icon,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: tint, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.outlineVariant,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GlicareBottomNav extends StatelessWidget {
  const GlicareBottomNav({
    super.key,
    required this.activeIndex,
    this.onTap,
    this.fab,
  });

  final int activeIndex;
  final ValueChanged<int>? onTap;
  final Widget? fab;

  static const items = [
    _NavItem(Icons.home_outlined, Icons.home, 'Início'),
    _NavItem(Icons.insights_outlined, Icons.insights, 'Gráficos'),
    _NavItem(null, null, ''),
    _NavItem(Icons.notifications_outlined, Icons.notifications, 'Alertas'),
    _NavItem(Icons.person_outline, Icons.person, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 90,
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.06),
              offset: const Offset(0, -12),
              blurRadius: 32,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (i) {
                  final item = items[i];
                  if (item.label.isEmpty) return const SizedBox(width: 56);
                  final active = i == activeIndex;
                  return _NavButton(
                    item: item,
                    active: active,
                    onTap: () => onTap?.call(i),
                  );
                }),
              ),
            ),
            Positioned(
              top: -16,
              child: fab ?? _DefaultFab(onTap: () => onTap?.call(2)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData? icon;
  final IconData? iconFilled;
  final String label;
  const _NavItem(this.icon, this.iconFilled, this.label);
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.active, this.onTap});

  final _NavItem item;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.onSurfaceVariant.withValues(alpha: 0.5);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withValues(alpha: 0.08) : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? item.iconFilled : item.icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DefaultFab extends StatelessWidget {
  const _DefaultFab({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      elevation: 8,
      shadowColor: AppColors.primary.withValues(alpha: 0.4),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
