import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central presentation settings. The existing dark palette is preserved.
class AppTheme {
  static ThemeData dark() {
    GoogleFonts.config.allowRuntimeFetching = false;
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFAD85FF),
          brightness: Brightness.dark,
          primary: const Color(0xFFC3AEFF),
          secondary: const Color(0xFFFFC78D),
          surface: const Color(0xFF19191C),
          onSurfaceVariant: const Color(0xFFCECED5),
          surfaceContainerHighest: const Color(0xFF303034),
          onSurface: const Color(0xFFF7F7F8)),
      scaffoldBackgroundColor: const Color(0xFF0E0E10),
      appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0E0E10), scrolledUnderElevation: 0),
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
              minimumSize: const Size(48, 48),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              minimumSize: const Size(48, 48),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12))),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(minimumSize: const Size(48, 48))),
      iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              tapTargetSize: MaterialTapTargetSize.padded)),
      cardTheme: CardThemeData(
          color: const Color(0xFF1C1C20),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: Color(0xFF333338)))),
      navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color(0xFF18181B),
          indicatorColor: Color(0xFF554478)),
      inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF222226),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide(color: Color(0xFF414147)))),
    );
    final body = GoogleFonts.latoTextTheme(base.textTheme);
    TextStyle heading(TextStyle? style) =>
        GoogleFonts.poppins(textStyle: style, fontWeight: FontWeight.w600);
    return base.copyWith(
        textTheme: body.copyWith(
      displayLarge: heading(body.displayLarge),
      displayMedium: heading(body.displayMedium),
      displaySmall: heading(body.displaySmall),
      headlineLarge: heading(body.headlineLarge),
      headlineMedium: heading(body.headlineMedium),
      headlineSmall: heading(body.headlineSmall),
      titleLarge: heading(body.titleLarge),
      titleMedium: heading(body.titleMedium),
      titleSmall: heading(body.titleSmall),
    ));
  }
}
