import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Single theme — no dark mode untuk initial release.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: AppColors.royalBlue,
      onPrimary: AppColors.offWhite,
      secondary: AppColors.tealBlue,
      onSecondary: AppColors.offWhite,
      error: AppColors.danger,
      onError: AppColors.offWhite,
      surface: AppColors.offWhite,
      onSurface: AppColors.richBlack,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.offWhite,

      // Typography — mapping sesuai design.md section 3
      // (display, title, body, label, caption)
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.richBlack,
        ), // display
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.richBlack,
        ), // title
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: AppColors.richBlack,
        ), // body
        labelMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.richBlack,
        ), // label
        bodySmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.normal,
          color: AppColors.richBlack,
        ), // caption
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.offWhite,
        foregroundColor: AppColors.richBlack,
        elevation: 0,
        centerTitle: false,
      ),

      // Primary CTA — full-width sticky button, radius-button = 8
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.royalBlue,
          foregroundColor: AppColors.offWhite,
          disabledBackgroundColor: AppColors.royalBlue.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ).copyWith(
          // pressed state -> deepNavy sesuai design.md
          overlayColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.pressed)
                ? AppColors.deepNavy
                : null,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.offWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // radius-card
          side: BorderSide(color: AppColors.borderSubtle),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.offWhite,
        selectedItemColor: AppColors.tealBlue, // accent, bukan primary
        unselectedItemColor: AppColors.richBlack.withValues(alpha: 0.4),
        type: BottomNavigationBarType.fixed,
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          backgroundColor: AppColors.backgroundIconButton,
          foregroundColor: AppColors.foregroundIconButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      )
    );
  }
}