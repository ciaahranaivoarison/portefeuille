import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

const _nomsMois = [
  'Janvier',
  'Février',
  'Mars',
  'Avril',
  'Mai',
  'Juin',
  'Juillet',
  'Août',
  'Septembre',
  'Octobre',
  'Novembre',
  'Décembre',
];

/// Ex. : « Octobre 2026 ».
String libelleMois(DateTime d) => '${_nomsMois[d.month - 1]} ${d.year}';

/// Un budget est mensuel : « 300 000 Ar / mois » vaut pour tous les mois.
const _tousLesMois = '*';

/// Un budget mensuel avec ce qui a déjà été dépensé dans la catégorie.
class BudgetItem {
  const BudgetItem({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.spent,
  });

  final int id;
  final int categoryId;
  final String categoryName;
  final int amount; // budget prévu par mois
  final int spent; // déjà dépensé dans le mois affiché

  int get remaining => amount - spent;
  double get ratio => amount == 0 ? 0 : spent / amount;
}

class Budgets {
  Budgets._();
  static final Budgets instance = Budgets._();

  String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Budgets (valables chaque mois) avec les dépenses du mois demandé.
  Future<List<BudgetItem>> pourMois(DateTime mois) async {
    final db = await AppDatabase.instance.database;

    // Reprend les anciens budgets liés à un seul mois : ils valent
    // désormais pour tous les mois.
    await db.rawUpdate(
      'UPDATE OR IGNORE budgets SET month = ? WHERE month != ?',
      [_tousLesMois, _tousLesMois],
    );
    await db.delete(
      'budgets',
      where: 'month != ?',
      whereArgs: [_tousLesMois],
    );

    final debut = _iso(DateTime(mois.year, mois.month, 1));
    final fin = _iso(DateTime(mois.year, mois.month + 1, 1));
    final rows = await db.rawQuery('''
      SELECT b.id, b.category_id, c.name AS category_name, b.amount,
        COALESCE((
          SELECT SUM(t.amount) FROM transactions t
          WHERE t.type = 'expense'
            AND t.category_id = b.category_id
            AND t.date >= ? AND t.date < ?
        ), 0) AS spent
      FROM budgets b
      JOIN categories c ON c.id = b.category_id
      WHERE b.month = ?
      ORDER BY c.name
    ''', [debut, fin, _tousLesMois]);

    return rows
        .map(
          (r) => BudgetItem(
            id: r['id'] as int,
            categoryId: r['category_id'] as int,
            categoryName: r['category_name'] as String,
            amount: (r['amount'] as num).toInt(),
            spent: (r['spent'] as num).toInt(),
          ),
        )
        .toList();
  }

  /// Crée le budget mensuel d'une catégorie, ou le remplace.
  Future<void> definir({
    required int categorieId,
    required int montant,
  }) async {
    if (montant <= 0) {
      throw ArgumentError('Le budget doit être supérieur à 0.');
    }
    final db = await AppDatabase.instance.database;
    await db.insert(
      'budgets',
      {
        'category_id': categorieId,
        'month': _tousLesMois,
        'amount': montant,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> supprimer(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }
}