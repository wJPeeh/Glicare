import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF005F9C);
  static const Color primaryDim = Color(0xFF005389);
  static const Color primaryContainer = Color(0xFF5EB0FF);
  static const Color onPrimary = Color(0xFFECF3FF);
  static const Color onPrimaryContainer = Color(0xFF002E50);

  static const Color secondary = Color(0xFF00675F);
  static const Color secondaryDim = Color(0xFF005A53);
  static const Color secondaryContainer = Color(0xFF78F7E9);
  static const Color onSecondary = Color(0xFFBFFFF6);
  static const Color onSecondaryContainer = Color(0xFF005C55);

  static const Color tertiary = Color(0xFF815100);
  static const Color tertiaryDim = Color(0xFF714600);
  static const Color tertiaryContainer = Color(0xFFF8A010);
  static const Color tertiaryFixedDim = Color(0xFFE79400);
  static const Color onTertiary = Color(0xFFFFF0E3);
  static const Color onTertiaryContainer = Color(0xFF4A2C00);

  static const Color error = Color(0xFFB31B25);
  static const Color errorDim = Color(0xFF9F0519);
  static const Color errorContainer = Color(0xFFFB5151);
  static const Color onError = Color(0xFFFFEFEE);
  static const Color onErrorContainer = Color(0xFF570008);

  static const Color background = Color(0xFFF5F7F9);
  static const Color surface = Color(0xFFF5F7F9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEEF1F3);
  static const Color surfaceContainer = Color(0xFFE5E9EB);
  static const Color surfaceContainerHigh = Color(0xFFDFE3E6);
  static const Color surfaceContainerHighest = Color(0xFFD9DDE0);

  static const Color onSurface = Color(0xFF2C2F31);
  static const Color onSurfaceVariant = Color(0xFF595C5E);
  static const Color outline = Color(0xFF747779);
  static const Color outlineVariant = Color(0xFFABADAF);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, primaryDim],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [secondary, secondaryDim],
  );

  static List<BoxShadow> softShadow({double y = 12, double blur = 32, double opacity = 0.06}) =>
      [
        BoxShadow(
          color: onSurface.withValues(alpha: opacity),
          offset: Offset(0, y),
          blurRadius: blur,
        ),
      ];

  static List<BoxShadow> primaryGlow({double opacity = 0.2}) => [
        BoxShadow(
          color: primary.withValues(alpha: opacity),
          offset: const Offset(0, 12),
          blurRadius: 32,
        ),
      ];
}
