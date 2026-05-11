import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GlicareLogo extends StatelessWidget {
  const GlicareLogo({
    super.key,
    this.size = 80,
    this.background = Colors.white,
    this.dropColor = AppColors.primary,
    this.checkColor = AppColors.secondary,
    this.rotated = true,
  });

  final double size;
  final Color background;
  final Color dropColor;
  final Color checkColor;
  final bool rotated;

  @override
  Widget build(BuildContext context) {
    final inner = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.4),
        boxShadow: AppColors.softShadow(y: 16, blur: 32, opacity: 0.18),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.water_drop, color: dropColor, size: size * 0.6),
          Positioned(
            top: size * 0.32,
            child: Icon(Icons.check, color: checkColor, size: size * 0.28),
          ),
        ],
      ),
    );

    if (!rotated) return inner;
    return Transform.rotate(angle: 0.05, child: inner);
  }
}
