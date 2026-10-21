import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

/// Une catégorie avec le nombre d'opérations qui l'utilisent.
class CategoryInfo {
  const CategoryInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.isDefault,
    required this.usage,
  });

  final int id;
  final String name;
  final String type; // 'expense' ou 'income'
  final bool isDefault; // catégorie de la fiche : verrouillée
  final int usage; // nombre d'opérations
}

/// Ajout, modification et suppression des catégories de l'utilisateur.
class Categories {
  Categories._();
  static final Categories instance = Categories._();

  Future<List<CategoryInfo>> lister(String type) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery('''
      SELECT c.id, c.name, c.type, c.is_default,
        (SELECT COUNT(*) FROM transactions t
         WHERE t.category_id = c.id) AS usage
      FROM categories c
      WHERE c.type = ?
      ORDER BY c.is_default DESC, c.id
    ''', [type]);
    return rows
        .map(
          (r) => CategoryInfo(
            id: r['id'] as int,
            name: r['name'] as String,
            type: r['type'] as String,
            isDefault: (r['is_default'] as num).toInt() == 1,
            usage: (r['usage'] as num).toInt(),
          ),
        )
        .toList();
  }

  Future<void> _verifierNom(
    Database db,
    String nom,
    String type, {
    int? sauf,
  }) async {
    if (nom.trim().isEmpty) {
      throw ArgumentError('Saisissez un nom pour la catégorie.');
    }
    final rows = await db.query(
      'categories',
      columns: ['id', 'name'],
      where: 'type = ?',
      whereArgs: [type],
    );
    final existe = rows.any(
      (r) =>
          r['id'] != sauf &&
          (r['name'] as String).toLowerCase() == nom.trim().toLowerCase(),
    );
    if (existe) {
      throw ArgumentError('Une catégorie porte déjà ce nom.');
    }
  }

  Future<void> creer({required String nom, required String type}) async {
    final db = await AppDatabase.instance.database;
    await _verifierNom(db, nom, type);
    await db.insert('categories', {
      'name': nom.trim(),
      'type': type,
      'is_default': 0,
    });
  }

  Future<void> modifier({
    required int id,
    required String nom,
    required String type,
  }) async {
    final db = await AppDatabase.instance.database;
    await _verifierNom(db, nom, type, sauf: id);
    await db.update(
      'categories',
      {'name': nom.trim()},
      where: 'id = ? AND is_default = 0',
      whereArgs: [id],
    );
  }

  /// Supprime une catégorie de l'utilisateur. Ses opérations deviennent
  /// « Sans catégorie » et ses budgets sont retirés.
  Future<void> supprimer(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete(
      'categories',
      where: 'id = ? AND is_default = 0',
      whereArgs: [id],
    );
  }
}