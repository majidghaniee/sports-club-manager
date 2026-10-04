import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// سیستم رنگ مبتنی بر HSL (الهام‌گرفته از OKLCH)
class AppColors {
  // HSL(168, 60%, 40%)
  static HSLColor get primaryHsl => const HSLColor.fromAHSL(1, 168, 0.60, 0.40);
  static Color get primary => primaryHsl.toColor();
  static Color primaryAt(double lightness) =>
      primaryHsl.withLightness(lightness.clamp(0.0, 1.0)).toColor();

  /// رمپ نوترون ۱۰ مرحله‌ای از نزدیک سفید تا نزدیک سیاه
  static List<Color> get neutral => List.generate(10, (i) {
        final l = 0.97 - (i * 0.09); // 0.97 .. 0.16
        return HSLColor.fromAHSL(1, 200, 0.10, l).toColor();
      });

  static Color get amber => const HSLColor.fromAHSL(1, 38, 0.92, 0.50).toColor();
  static Color get red => const HSLColor.fromAHSL(1, 4, 0.72, 0.50).toColor();
}

class AppTheme {
  static const String fontFamily = 'Vazirmatn';

  static TextTheme _text(ColorScheme cs) => TextTheme(
        displaySmall: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: cs.onSurface),
        headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: cs.onSurface),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: cs.onSurface),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface),
        bodyLarge: TextStyle(fontSize: 15, color: cs.onSurface),
        bodyMedium: TextStyle(fontSize: 14, color: cs.onSurface),
        bodySmall: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      );

  static ThemeData _base(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final neutral = AppColors.neutral;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    );
    final cs = scheme.copyWith(primary: AppColors.primaryAt(isDark ? 0.55 : 0.40),
        secondary: AppColors.amber, error: AppColors.red,
        surface: isDark ? neutral[9] : neutral[0],
        background: isDark ? neutral[8] : neutral[1]);
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      fontFamily: fontFamily,
      textTheme: _text(cs),
      scaffoldBackgroundColor: cs.background,
      appBarTheme: AppBarTheme(
        backgroundColor: cs.background,
        foregroundColor: cs.onSurface,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.outlineVariant.withOpacity(0.5)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(64, 48),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? neutral[9] : neutral[0],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.outlineVariant)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.outlineVariant)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.primary.withOpacity(0.15),
        labelTextStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 12, color: cs.onSurface, fontWeight: FontWeight.w600)),
        elevation: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary, foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: DividerThemeData(color: cs.outlineVariant.withOpacity(0.5)),
    );
  }

  static ThemeData get light => _base(Brightness.light);
  static ThemeData get dark => _base(Brightness.dark);
}
