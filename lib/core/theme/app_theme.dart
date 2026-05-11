import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color onSurface, Color onSurfaceVariant) {
    final headline = GoogleFonts.plusJakartaSansTextTheme();
    final body = GoogleFonts.manropeTextTheme();
    return TextTheme(
      displayLarge: headline.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: onSurface,
        letterSpacing: -1.5,
      ),
      displayMedium: headline.displayMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: onSurface,
        letterSpacing: -1,
      ),
      displaySmall: headline.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: onSurface,
      ),
      headlineLarge: headline.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: onSurface,
      ),
      headlineMedium: headline.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      headlineSmall: headline.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      titleLarge: headline.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      titleMedium: headline.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleSmall: headline.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: body.bodyLarge?.copyWith(color: onSurface),
      bodyMedium: body.bodyMedium?.copyWith(color: onSurface),
      bodySmall: body.bodySmall?.copyWith(color: onSurfaceVariant),
      labelLarge: body.labelLarge?.copyWith(
        color: onSurface,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: body.labelMedium?.copyWith(color: onSurfaceVariant),
      labelSmall: body.labelSmall?.copyWith(color: onSurfaceVariant),
    );
  }

  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _textTheme(AppColors.onSurface, AppColors.onSurfaceVariant),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      iconTheme: const IconThemeData(color: AppColors.primary),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
