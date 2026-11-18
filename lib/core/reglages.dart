import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../data/app_database.dart';

/// Réglages de l'application, enregistrés dans la table `settings` :
/// mode d'apparence (clair, sombre, automatique) et langue.
class Reglages extends ChangeNotifier {
  Reglages._();
  static final Reglages instance = Reglages._();

  static const _cleMode = 'apparence_mode';
  static const _cleLangue = 'langue';

  /// Langues proposées : code, drapeau, nom dans la langue elle-même.
  static const langues = <(String, String, String)>[
    ('fr', ':flag-fr:', 'Français'),
    ('en', ':flag-gb:', 'English'),
    ('mg', ':flag-mg:', 'Malagasy'),
  ];

  ThemeMode _mode = ThemeMode.light;
  String _langue = 'fr';

  /// Mode d'apparence : clair, sombre ou automatique (suit le téléphone).
  ThemeMode get mode => _mode;

  /// Code de la langue : 'fr', 'en' ou 'mg'.
  String get langue => _langue;

  /// Nom de la langue actuelle, écrit dans cette langue.
  String get nomLangue =>
      langues.firstWhere((l) => l.$1 == _langue, orElse: () => langues.first).$3;

  /// Langue des composants Android (calendrier, boutons...).
  /// Le malgache n'existe pas dans Flutter : on y utilise le français.
  Locale get locale =>
      _langue == 'en' ? const Locale('en') : const Locale('fr');

  static String _versTexte(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'clair',
        ThemeMode.dark => 'sombre',
        ThemeMode.system => 'auto',
      };

  static ThemeMode _depuisTexte(String? texte) => switch (texte) {
        'sombre' => ThemeMode.dark,
        'auto' => ThemeMode.system,
        _ => ThemeMode.light,
      };

  Future<String?> _lire(Database db, String cle) async {
    final rows = await db.query(
      'settings',
      where: '"key" = ?',
      whereArgs: [cle],
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> _ecrire(String cle, String valeur) async {
    final db = await AppDatabase.instance.database;
    await db.insert(
      'settings',
      {'key': cle, 'value': valeur},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Lit les réglages enregistrés (à appeler au démarrage).
  Future<void> charger() async {
    final db = await AppDatabase.instance.database;
    _mode = _depuisTexte(await _lire(db, _cleMode));
    final langue = (await _lire(db, _cleLangue)) ?? 'fr';
    _langue = (langue == 'en' || langue == 'mg') ? langue : 'fr';
    notifyListeners();
  }

  Future<void> definirMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    await _ecrire(_cleMode, _versTexte(mode));
  }

  Future<void> definirLangue(String code) async {
    if (code == _langue) return;
    _langue = code;
    notifyListeners();
    _toutReconstruire();
    await _ecrire(_cleLangue, code);
  }
}

/// Demande à tous les écrans de se redessiner, pour que les textes
/// d'aide et les infobulles changent de langue eux aussi.
void _toutReconstruire() {
  void reconstruire(Element element) {
    element.markNeedsBuild();
    element.visitChildren(reconstruire);
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    WidgetsBinding.instance.rootElement?.visitChildren(reconstruire);
  });
}
