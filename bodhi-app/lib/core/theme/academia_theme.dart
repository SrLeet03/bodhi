import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bodhi Academia Design System
/// ─────────────────────────────
/// Dark mahogany backgrounds, polished brass accents, crimson emphasis,
/// serif typography, corner flourishes, ornate dividers.

class AcademiaColors {
  // Foundation Colors (Library at Night)
  static const background = Color(0xFF1C1714);      // Deep Mahogany
  static const backgroundAlt = Color(0xFF251E19);    // Aged Oak
  static const foreground = Color(0xFFE8DFD4);       // Antique Parchment
  static const muted = Color(0xFF3D332B);            // Worn Leather
  static const mutedForeground = Color(0xFF9C8B7A);  // Faded Ink
  static const border = Color(0xFF4A3F35);           // Wood Grain

  // Accent Colors
  static const brass = Color(0xFFC9A962);            // Polished Brass
  static const brassLight = Color(0xFFD4B872);       // Brass highlight
  static const brassDark = Color(0xFFB8953F);        // Brass shadow
  static const crimson = Color(0xFF8B2635);          // Library Crimson
  static const crimsonLight = Color(0xFFA83244);     // Lighter crimson

  // Brass gradient
  static const brassGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [brassLight, brass, brassDark],
  );

  static const crimsonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [crimsonLight, crimson, Color(0xFF6D1D2A)],
  );
}

class AcademiaTypography {
  static TextStyle heading({double size = 28, Color? color, FontWeight? weight}) {
    return GoogleFonts.cormorantGaramond(
      fontSize: size,
      fontWeight: weight ?? FontWeight.w500,
      color: color ?? AcademiaColors.foreground,
      height: 1.1,
    );
  }

  static TextStyle body({double size = 17, Color? color, bool italic = false}) {
    return GoogleFonts.crimsonPro(
      fontSize: size,
      fontWeight: FontWeight.w400,
      color: color ?? AcademiaColors.foreground,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      height: 1.625,
    );
  }

  static TextStyle label({double size = 10, Color? color}) {
    return GoogleFonts.cinzel(
      fontSize: size,
      fontWeight: FontWeight.w500,
      color: color ?? AcademiaColors.brass,
      letterSpacing: size * 0.25,
    );
  }

  static TextStyle display({double size = 42, Color? color}) {
    return GoogleFonts.cinzel(
      fontSize: size,
      fontWeight: FontWeight.w500,
      color: color ?? AcademiaColors.brass,
      letterSpacing: size * 0.05,
    );
  }

  static TextStyle button({double size = 13, Color? color}) {
    return GoogleFonts.cinzel(
      fontSize: size,
      fontWeight: FontWeight.w500,
      color: color ?? AcademiaColors.background,
      letterSpacing: size * 0.15,
    );
  }
}

class AcademiaTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AcademiaColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AcademiaColors.brass,
        secondary: AcademiaColors.crimson,
        surface: AcademiaColors.backgroundAlt,
        error: AcademiaColors.crimson,
        onPrimary: AcademiaColors.background,
        onSecondary: AcademiaColors.foreground,
        onSurface: AcademiaColors.foreground,
      ),
      cardColor: AcademiaColors.backgroundAlt,
      dividerColor: AcademiaColors.border,
      appBarTheme: AppBarTheme(
        backgroundColor: AcademiaColors.backgroundAlt,
        foregroundColor: AcademiaColors.foreground,
        elevation: 0,
        titleTextStyle: AcademiaTypography.heading(size: 22),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: AcademiaTypography.button(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: AcademiaColors.brass, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          foregroundColor: AcademiaColors.brass,
          textStyle: AcademiaTypography.button(color: AcademiaColors.brass),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AcademiaColors.backgroundAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AcademiaColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AcademiaColors.brass, width: 2),
        ),
        hintStyle: AcademiaTypography.body(color: AcademiaColors.mutedForeground, italic: true),
        labelStyle: AcademiaTypography.label(),
      ),
    );
  }
}
