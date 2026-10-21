import 'app_database.dart';

class Category {
  const Category({required this.id, required this.name});

  final int id;
  final String name;
}

/// Lecture des catégories et enregistrement des opérations.
class Operations {
  Operations._();
  static final Operations instance = Operations._();

  String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Catégories d'un type : 'expense' (dépenses) ou 'income' (revenus).
  Future<List<Category>> categories(String type) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'id',
    );
    return rows
        .map((r) => Category(id: r['id'] as int, name: r['name'] as String))
        .toList();
  }

  /// Enregistre une dépense, un revenu ou un transfert.
  Future<void> ajouter({
    required String type,
    required int montant,
    required int compteId,
    int? versCompteId,
    int? categorieId,
    required DateTime date,
    String? note,
  }) async {
    if (montant <= 0) {
      throw ArgumentError('Le montant doit être supérieur à 0.');
    }
    if (type == 'transfer') {
      if (versCompteId == null || versCompteId == compteId) {
        throw ArgumentError(
          'Choisissez deux comptes différents pour le transfert.',
        );
      }
    }

    final db = await AppDatabase.instance.database;
    await db.insert('transactions', {
      'type': type,
      'amount': montant,
      'account_id': compteId,
      'to_account_id': type == 'transfer' ? versCompteId : null,
      'category_id': type == 'transfer' ? null : categorieId,
      'date': _iso(date),
      'note': (note == null || note.trim().isEmpty) ? null : note.trim(),
    });
  }
}