import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Couleurs officielles Mutooni (issues de la maquette)
class AppColors {
  static const Color primaryBlue      = Color(0xFF0062FF);
  static const Color sidebarBg        = Color(0xFFF5F7FA);
  static const Color sidebarSelected  = primaryBlue;
  static const Color sidebarText      = Colors.black87;

  static const Color success          = Color(0xFF42BE65);
  static const Color warning          = Color(0xFFF1C21B);
  static const Color danger           = Color(0xFFDA1E28);
}

/// Thème global (Material 3)
class AppTheme {
  /// Thème clair (par défaut)
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.interTextTheme(),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      );

  /// Thème sombre (optionnel)
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(
          Typography.whiteCupertino,
        ),
      );
}
