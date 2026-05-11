import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.gradient,
    this.icon,
    this.height = 56,
    this.borderRadius = 999,
    this.foreground = Colors.white,
    this.boxShadow,
  });

  final String label;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final IconData? icon;
  final double height;
  final double borderRadius;
  final Color foreground;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient ?? AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: boxShadow ?? AppColors.primaryGlow(),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, color: foreground, size: 22),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
