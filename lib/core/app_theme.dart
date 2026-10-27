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
      outline: AppColors.sable,
    );

    final bordure = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.sable),
    );
    final formeBouton = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontTexte,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.creme,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          //TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
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
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.sable),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.sable,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.blanc,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: bordure,
        enabledBorder: bordure,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.noyer, width: 1.6),
        ),
        hintStyle: const TextStyle(color: Color(0xFFA8957F)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.noyer,
          foregroundColor: AppColors.blanc,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: formeBouton,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.noyer,
          side: BorderSide(color: AppColors.noyer.withValues(alpha: 0.55)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: formeBouton,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.noyer,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.noyer,
        foregroundColor: AppColors.blanc,
        elevation: 3,
        extendedTextStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cacao,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: const TextStyle(
          color: AppColors.creme,
          fontFamily: fontTexte,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.blanc,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          fontFamily: fontTitre,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.cacao,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.noyer,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (etats) => etats.contains(WidgetState.selected)
                ? AppColors.noyer
                : AppColors.blanc,
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (etats) => etats.contains(WidgetState.selected)
                ? AppColors.blanc
                : AppColors.cacao,
          ),
          side: WidgetStateProperty.all(
            const BorderSide(color: AppColors.sable),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>(
          (etats) => etats.contains(WidgetState.selected)
              ? AppColors.blanc
              : AppColors.noyer,
        ),
        trackColor: WidgetStateProperty.resolveWith<Color?>(
          (etats) => etats.contains(WidgetState.selected)
              ? AppColors.noyer
              : AppColors.sable,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
          (etats) => etats.contains(WidgetState.selected)
              ? Colors.transparent
              : AppColors.noyer,
        ),
      ),
    );
  }
}