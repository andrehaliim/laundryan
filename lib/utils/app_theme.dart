import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _charcoal = Color(0xFF1E252D);
  static const _sky = Color(0xFF87CEEB);

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: _sky,
    onPrimary: _charcoal,
    primaryContainer: Color(0xFFD6EFFA),
    onPrimaryContainer: Color(0xFF0F4A61),
    secondary: Color(0xFFFFB6C1),
    onSecondary: _charcoal,
    secondaryContainer: Color(0xFFFFDDE2),
    onSecondaryContainer: Color(0xFF7A1E2F),
    tertiary: Color(0xFF90EE90),
    onTertiary: _charcoal,
    tertiaryContainer: Color(0xFFD5F8D5),
    onTertiaryContainer: Color(0xFF195619),
    error: Color(0xFFBA1A1A),
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF93000A),
    surface: Color(0xFFF8FAFC),
    onSurface: _charcoal,
    onSurfaceVariant: Color(0xFF586574),
    outline: Color(0xFF94A3B8),
    outlineVariant: Color(0xFFE2E8F0),
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: Color(0xFFF1F5F9),
    surfaceContainer: Color(0xFFEDF2F7),
    surfaceContainerHigh: Color(0xFFE8EEF4),
    surfaceContainerHighest: Color(0xFFE2E8F0),
    inversePrimary: Color(0xFF0C6780),
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: _sky,
    onPrimary: _charcoal,
    primaryContainer: Color(0xFF1E3A47),
    onPrimaryContainer: Color(0xFFB8E4F5),
    secondary: Color(0xFFFFB6C1),
    onSecondary: _charcoal,
    secondaryContainer: Color(0xFF4A2A32),
    onSecondaryContainer: Color(0xFFFFC9D1),
    tertiary: Color(0xFF90EE90),
    onTertiary: _charcoal,
    tertiaryContainer: Color(0xFF24452A),
    onTertiaryContainer: Color(0xFFB9F5B9),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF12161A),
    onSurface: Color(0xFFE6EBF0),
    onSurfaceVariant: Color(0xFF9AA7B4),
    outline: Color(0xFF5B6773),
    outlineVariant: Color(0xFF2A323B),
    surfaceContainerLowest: Color(0xFF0E1114),
    surfaceContainerLow: Color(0xFF161B21),
    surfaceContainer: Color(0xFF1A2027),
    surfaceContainerHigh: Color(0xFF202730),
    surfaceContainerHighest: Color(0xFF262E38),
    inversePrimary: Color(0xFF0C6780),
  );

  static ThemeData get light => _build(_lightScheme);
  static ThemeData get dark => _build(_darkScheme);

  static RoundedRectangleBorder _shape(double r, [BorderSide? side]) =>
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(r),
        side: side ?? BorderSide.none,
      );

  static OutlineInputBorder _border(Color c, [double w = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: c, width: w),
      );

  static ThemeData _build(ColorScheme s) {
    final isLight = s.brightness == Brightness.light;
    final cardColor = isLight ? s.surfaceContainerLowest : s.surfaceContainer;
    final link = isLight ? const Color(0xFF0C6780) : s.primary;
    final inputBorder = isLight ? const Color(0xFFCBD5E1) : s.outlineVariant;

    final family = GoogleFonts.plusJakartaSans().fontFamily;

    final base = ThemeData(
      brightness: s.brightness,
      fontFamily: family,
    ).textTheme.apply(bodyColor: s.onSurface, displayColor: s.onSurface);

    TextStyle plusJakartaSans(double size, FontWeight w, {double? height}) =>
        GoogleFonts.plusJakartaSans(
          fontSize: size,
          fontWeight: w,
          height: height,
          color: s.onSurface,
        );

    final text = base.copyWith(
      headlineSmall: plusJakartaSans(24, FontWeight.w700),
      titleLarge: plusJakartaSans(18, FontWeight.w600),
      titleMedium: plusJakartaSans(16, FontWeight.w600),
      titleSmall: plusJakartaSans(14, FontWeight.w600),
      bodyMedium: plusJakartaSans(14, FontWeight.w400, height: 1.5),
      bodySmall: plusJakartaSans(12, FontWeight.w400, height: 1.4),
      labelSmall: plusJakartaSans(11, FontWeight.w500),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: s,
      scaffoldBackgroundColor: s.surface,
      fontFamily: family,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: isLight
            ? s.surfaceContainerLowest
            : s.surfaceContainer,
        foregroundColor: s.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: isLight ? 2 : 0,
        shadowColor: const Color(0x141E252D),
        margin: EdgeInsets.zero,
        shape: _shape(20, BorderSide(color: s.outlineVariant)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: s.primary,
          foregroundColor: s.onPrimary,
          minimumSize: const Size(64, 48),
          shape: _shape(10),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: s.onSurface,
          minimumSize: const Size(64, 48),
          side: BorderSide(color: inputBorder),
          shape: _shape(10),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: link, shape: _shape(10)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: _border(inputBorder),
        enabledBorder: _border(inputBorder),
        focusedBorder: _border(s.primary, 2),
        errorBorder: _border(s.error),
        focusedErrorBorder: _border(s.error, 2),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(_shape(10)),
          side: WidgetStatePropertyAll(BorderSide(color: inputBorder)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (st) => st.contains(WidgetState.selected) ? s.primary : null,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (st) =>
                st.contains(WidgetState.selected) ? s.onPrimary : s.onSurface,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: s.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith(
          (st) => IconThemeData(
            color: st.contains(WidgetState.selected)
                ? s.onPrimaryContainer
                : s.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (st) => text.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: st.contains(WidgetState.selected)
                ? s.onSurface
                : s.onSurfaceVariant,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: s.primary,
        foregroundColor: s.onPrimary,
        shape: _shape(30),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        modalBackgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: _shape(20),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: _shape(10),
      ),
      dividerTheme: DividerThemeData(color: s.outlineVariant),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.selected) ? cardColor : s.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.selected)
              ? s.primary
              : s.surfaceContainerHighest,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.selected) ? s.primary : inputBorder,
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: _shape(20, BorderSide(color: s.outlineVariant)),
        headerBackgroundColor: cardColor,
        headerForegroundColor: s.onSurface,
        headerHelpStyle: text.labelMedium?.copyWith(
          color: s.onSurfaceVariant,
          letterSpacing: 0.4,
        ),
        headerHeadlineStyle: text.headlineSmall,
        dividerColor: s.outlineVariant,
        weekdayStyle: text.labelMedium?.copyWith(
          color: s.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        dayStyle: text.bodyMedium,
        dayShape: WidgetStatePropertyAll(_shape(10)),
        dayForegroundColor: WidgetStateProperty.resolveWith((st) {
          if (st.contains(WidgetState.disabled)) {
            return s.onSurface.withValues(alpha: 0.38);
          }
          return st.contains(WidgetState.selected) ? s.onPrimary : s.onSurface;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.selected) ? s.primary : null,
        ),
        dayOverlayColor: WidgetStatePropertyAll(
          s.primary.withValues(alpha: 0.12),
        ),
        todayForegroundColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.selected) ? s.onPrimary : link,
        ),
        todayBackgroundColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.selected) ? s.primary : null,
        ),
        todayBorder: BorderSide(color: s.primary, width: 1.5),
        yearStyle: text.bodyMedium,
        yearShape: WidgetStatePropertyAll(_shape(10)),
        yearForegroundColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.selected) ? s.onPrimary : s.onSurface,
        ),
        yearBackgroundColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.selected) ? s.primary : null,
        ),
        cancelButtonStyle: _pickerCancel(s, text),
        confirmButtonStyle: _pickerConfirm(s, text),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: cardColor,
        elevation: 0,
        shape: _shape(20, BorderSide(color: s.outlineVariant)),
        helpTextStyle: text.labelMedium?.copyWith(
          color: s.onSurfaceVariant,
          letterSpacing: 0.4,
        ),
        hourMinuteShape: _shape(12),
        hourMinuteColor: WidgetStateColor.resolveWith(
          (st) => st.contains(WidgetState.selected)
              ? s.primaryContainer
              : s.surfaceContainerLow,
        ),
        hourMinuteTextColor: WidgetStateColor.resolveWith(
          (st) => st.contains(WidgetState.selected)
              ? s.onPrimaryContainer
              : s.onSurface,
        ),
        dayPeriodShape: _shape(10),
        dayPeriodBorderSide: BorderSide(color: inputBorder),
        dayPeriodColor: WidgetStateColor.resolveWith(
          (st) => st.contains(WidgetState.selected)
              ? s.primaryContainer
              : Colors.transparent,
        ),
        dayPeriodTextColor: WidgetStateColor.resolveWith(
          (st) => st.contains(WidgetState.selected)
              ? s.onPrimaryContainer
              : s.onSurfaceVariant,
        ),
        dialBackgroundColor: s.surfaceContainerLow,
        dialHandColor: s.primary,
        dialTextColor: WidgetStateColor.resolveWith(
          (st) => st.contains(WidgetState.selected) ? s.onPrimary : s.onSurface,
        ),
        entryModeIconColor: s.onSurfaceVariant,
        cancelButtonStyle: _pickerCancel(s, text),
        confirmButtonStyle: _pickerConfirm(s, text),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _FadePageTransitionsBuilder(),
          TargetPlatform.iOS: _FadePageTransitionsBuilder(),
        },
      ),
    );
  }

  static ButtonStyle _pickerCancel(ColorScheme s, TextTheme text) =>
      TextButton.styleFrom(
        foregroundColor: s.onSurfaceVariant,
        minimumSize: const Size(64, 40),
        shape: _shape(10),
        textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      );

  static ButtonStyle _pickerConfirm(ColorScheme s, TextTheme text) =>
      TextButton.styleFrom(
        backgroundColor: s.primary,
        foregroundColor: s.onPrimary,
        minimumSize: const Size(64, 40),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: _shape(10),
        textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      );
}

/// Fade-only page transition (200ms ease-out) from design.md.
class _FadePageTransitionsBuilder extends PageTransitionsBuilder {
  const _FadePageTransitionsBuilder();

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    );
  }
}
