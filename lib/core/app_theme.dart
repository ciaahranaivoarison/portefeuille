import 'package:flutter/material.dart';

/// Palette « carnet de comptes » : papier crème, encre brune.
class AppColors {
  static const cacao = Color(0xFF3B2418); // texte et titres
  static const noyer = Color(0xFF6F4A33); // couleur principale
  static const caramel = Color(0xFFB9803F); // accent
  static const creme = Color(0xFFF7F1E8); // fond
  static const blanc = Color(0xFFFFFFFF); // surfaces
  static const sable = Color(0xFFE6D9C8); // séparateurs
  static const sauge = Color(0xFF5E7F5B); // revenus
  static const terracotta = Color(0xFFB5523B); // dépenses
}

class AppTheme {
  /// Police des titres et des montants.
  static const fontTitre = 'Fraunces';

  /// Police du texte courant.
  static const fontTexte = 'DMSans';

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.noyer,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.noyer,
      onPrimary: AppColors.blanc,
      secondary: AppColors.caramel,
      surface: AppColors.blanc,
      onSurface: AppColors.cacao,
      error: AppColors.terracotta,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontTexte,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.creme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.creme,
        foregroundColor: AppColors.cacao,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontTitre,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.cacao,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.blanc,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.sable),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.sable,
        thickness: 1,
      ),
    );
  }
}