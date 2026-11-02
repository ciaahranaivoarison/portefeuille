import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../data/app_database.dart';

/// Réglages de l'application, enregistrés dans la table `settings`.
class Reglages extends ChangeNotifier {
  Reglages._();
  static final Reglages instance = Reglages._();

  static const _cleMode = 'apparence_mode';

  ThemeMode _mode = ThemeMode.light;

  /// Mode d'apparence : clair, sombre ou automatique (suit le téléphone).
  ThemeMode get mode => _mode;

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

  /// Lit les réglages enregistrés (à appeler au démarrage).
  Future<void> charger() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'settings',
      where: '"key" = ?',
      whereArgs: [_cleMode],
    );
    _mode = rows.isEmpty
        ? ThemeMode.light
        : _depuisTexte(rows.first['value'] as String?);
    notifyListeners();
  }

  Future<void> definirMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    final db = await AppDatabase.instance.database;
    await db.insert(
      'settings',
      {'key': _cleMode, 'value': _versTexte(mode)},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}