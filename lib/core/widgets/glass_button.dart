import 'package:flutter/material.dart';

class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 56,
    this.borderRadius = 999,
    this.foreground = Colors.white,
    this.background,
    this.borderColor,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;
  final Color foreground;
  final Color? background;
  final Color? borderColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background ?? Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor ?? Colors.white.withValues(alpha: 0.18),
            width: 1,
          ),
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
                  if (icon != null) ...[
                    Icon(icon, color: foreground, size: 20),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
