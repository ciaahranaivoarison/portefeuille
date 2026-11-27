import 'package:flutter/material.dart';

/// Couleurs d'origine du « carnet de comptes » (mode clair).
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

/// Palette qui s'adapte au mode clair ou sombre.
@immutable
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.fond,
    required this.surface,
    required this.surfaceDouce,
    required this.texte,
    required this.texteDoux,
    required this.principal,
    required this.surPrincipal,
    required this.accent,
    required this.bordure,
    required this.revenu,
    required this.depense,
    required this.heroDebut,
    required this.heroFin,
    required this.surHero,
  });

  final Color fond;
  final Color surface;
  final Color surfaceDouce;
  final Color texte;
  final Color texteDoux;
  final Color principal;
  final Color surPrincipal;
  final Color accent;
  final Color bordure;
  final Color revenu;
  final Color depense;
  final Color heroDebut;
  final Color heroFin;
  final Color surHero;

  /// Mode clair : les couleurs d'origine.
  static const clair = Palette(
    fond: AppColors.creme,
    surface: AppColors.blanc,
    surfaceDouce: Color(0xFFF2E8D9),
    texte: AppColors.cacao,
    texteDoux: AppColors.noyer,
    principal: AppColors.noyer,
    surPrincipal: AppColors.blanc,
    accent: AppColors.caramel,
    bordure: AppColors.sable,
    revenu: AppColors.sauge,
    depense: AppColors.terracotta,
    heroDebut: Color(0xFF7D543A),
    heroFin: AppColors.caramel,
    surHero: Color(0xFFFFF8EC),
  );

  /// Mode sombre : des bruns chauds de chocolat, jamais de noir.
  static const sombre = Palette(
    fond: Color(0xFF2B2019),
    surface: Color(0xFF382B23),
    surfaceDouce: Color(0xFF42342A),
    texte: Color(0xFFF5ECDD),
    texteDoux: Color(0xFFCDB89E),
    principal: Color(0xFFD9A35B),
    surPrincipal: Color(0xFF2B2019),
    accent: Color(0xFFD9A35B),
    bordure: Color(0xFF53433A),
    revenu: Color(0xFF93B88E),
    depense: Color(0xFFE5917A),
    heroDebut: Color(0xFF6E4B34),
    heroFin: Color(0xFFB07A3C),
    surHero: Color(0xFFFFF4E2),
  );

  @override
  Palette copyWith() => this;

  @override
  Palette lerp(ThemeExtension<Palette>? other, double t) {
    if (other is! Palette) return this;
    Color m(Color a, Color b) => Color.lerp(a, b, t)!;
    return Palette(
      fond: m(fond, other.fond),
      surface: m(surface, other.surface),
      surfaceDouce: m(surfaceDouce, other.surfaceDouce),
      texte: m(texte, other.texte),
      texteDoux: m(texteDoux, other.texteDoux),
      principal: m(principal, other.principal),
      surPrincipal: m(surPrincipal, other.surPrincipal),
      accent: m(accent, other.accent),
      bordure: m(bordure, other.bordure),
      revenu: m(revenu, other.revenu),
      depense: m(depense, other.depense),
      heroDebut: m(heroDebut, other.heroDebut),
      heroFin: m(heroFin, other.heroFin),
      surHero: m(surHero, other.surHero),
    );
  }
}

/// Raccourci : `context.pal.texte`, `context.pal.surface`, etc.
extension PaletteContexte on BuildContext {
  Palette get pal => Theme.of(this).extension<Palette>() ?? Palette.clair;
}

class AppTheme {
  /// Police des titres et des montants.
  static const fontTitre = 'Fraunces';

  /// Police du texte courant.
  static const fontTexte = 'DMSans';

  static ThemeData get light => _construire(Palette.clair, Brightness.light);
  static ThemeData get dark => _construire(Palette.sombre, Brightness.dark);

  static ThemeData _construire(Palette p, Brightness luminosite) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.noyer,
      brightness: luminosite,
    ).copyWith(
      primary: p.principal,
      onPrimary: p.surPrincipal,
      secondary: p.accent,
      surface: p.surface,
      onSurface: p.texte,
      onSurfaceVariant: p.texteDoux,
      error: p.depense,
      outline: p.bordure,
      outlineVariant: p.bordure,
    );

    final bordureChamp = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: p.bordure),
    );
    final formeBouton = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    const texteBouton = TextStyle(fontWeight: FontWeight.w700, fontSize: 15);

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontTexte,
      colorScheme: scheme,
      extensions: <ThemeExtension<dynamic>>[p],
      scaffoldBackgroundColor: p.fond,
      canvasColor: p.fond,
      appBarTheme: AppBarTheme(
        backgroundColor: p.fond,
        foregroundColor: p.texte,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontTitre,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: p.texte,
        ),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: p.bordure),
        ),
      ),
      dividerTheme: DividerThemeData(color: p.bordure, thickness: 1),
      listTileTheme: ListTileThemeData(
        iconColor: p.texteDoux,
        textColor: p.texte,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: bordureChamp,
        enabledBorder: bordureChamp,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.principal, width: 1.6),
        ),
        hintStyle: TextStyle(color: p.texteDoux.withValues(alpha: 0.6)),
        labelStyle: TextStyle(color: p.texteDoux),
        prefixIconColor: p.texteDoux,
        suffixIconColor: p.texteDoux,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.principal,
        selectionHandleColor: p.principal,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.principal,
          foregroundColor: p.surPrincipal,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: formeBouton,
          textStyle: texteBouton,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.principal,
          side: BorderSide(color: p.principal.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: formeBouton,
          textStyle: texteBouton,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.principal,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.principal,
        foregroundColor: p.surPrincipal,
        elevation: 3,
        extendedTextStyle: texteBouton,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.principal,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: TextStyle(
          color: p.surPrincipal,
          fontFamily: fontTexte,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: TextStyle(
          fontFamily: fontTitre,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: p.texte,
        ),
        contentTextStyle: TextStyle(
          fontFamily: fontTexte,
          fontSize: 14.5,
          color: p.texte,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        showDragHandle: true,
        dragHandleColor: p.bordure,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface,
        selectedColor: p.principal,
        side: BorderSide(color: p.bordure),
        shape: const StadiumBorder(),
        labelStyle: TextStyle(color: p.texte, fontWeight: FontWeight.w600),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.principal,
        linearTrackColor: p.bordure,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (etats) => etats.contains(WidgetState.selected)
                ? p.principal
                : p.surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (etats) => etats.contains(WidgetState.selected)
                ? p.surPrincipal
                : p.texte,
          ),
          side: WidgetStateProperty.all(BorderSide(color: p.bordure)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>(
          (etats) => etats.contains(WidgetState.selected)
              ? p.surPrincipal
              : p.texteDoux,
        ),
        trackColor: WidgetStateProperty.resolveWith<Color?>(
          (etats) => etats.contains(WidgetState.selected)
              ? p.principal
              : p.surfaceDouce,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
          (etats) => etats.contains(WidgetState.selected)
              ? Colors.transparent
              : p.texteDoux,
        ),
      ),
    );
  }
}