import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

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
