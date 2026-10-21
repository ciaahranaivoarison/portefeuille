import 'app_database.dart';

class Category {
  const Category({required this.id, required this.name, required this.type});

  final int id;
  final String name;
  final String type; // 'expense' ou 'income'
}

/// Une opération lue dans la base, avec les noms du compte et de la catégorie.
class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.accountId,
    required this.accountName,
    this.toAccountId,
    this.toAccountName,
    this.categoryId,
    this.categoryName,
    required this.date,
    this.note,
  });

  final int id;
  final String type; // 'expense', 'income' ou 'transfer'
  final int amount;
  final int accountId;
  final String accountName;
  final int? toAccountId;
  final String? toAccountName;
  final int? categoryId;
  final String? categoryName;
  final DateTime date;
  final String? note;
}

/// Catégories, ajout, modification, suppression et liste des opérations.
class Operations {
  Operations._();
  static final Operations instance = Operations._();

  String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Category _categorie(Map<String, Object?> r) => Category(
        id: r['id'] as int,
        name: r['name'] as String,
        type: r['type'] as String,
      );

  /// Catégories d'un type : 'expense' (dépenses) ou 'income' (revenus).
  Future<List<Category>> categories(String type) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'id',
    );
    return rows.map(_categorie).toList();
  }

  /// Toutes les catégories (dépenses puis revenus).
  Future<List<Category>> toutesCategories() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('categories', orderBy: 'type, id');
    return rows.map(_categorie).toList();
  }

  void _verifier({
    required String type,
    required int montant,
    required int compteId,
    int? versCompteId,
  }) {
    if (montant <= 0) {
      throw ArgumentError('Le montant doit être supérieur à 0.');
    }
    if (type == 'transfer' &&
        (versCompteId == null || versCompteId == compteId)) {
      throw ArgumentError(
        'Choisissez deux comptes différents pour le transfert.',
      );
    }
  }

  Map<String, Object?> _valeurs({
    required String type,
    required int montant,
    required int compteId,
    int? versCompteId,
    int? categorieId,
    required DateTime date,
    String? note,
  }) =>
      {
        'type': type,
        'amount': montant,
        'account_id': compteId,
        'to_account_id': type == 'transfer' ? versCompteId : null,
        'category_id': type == 'transfer' ? null : categorieId,
        'date': _iso(date),
        'note': (note == null || note.trim().isEmpty) ? null : note.trim(),
      };

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
    _verifier(
      type: type,
      montant: montant,
      compteId: compteId,
      versCompteId: versCompteId,
    );
    final db = await AppDatabase.instance.database;
    await db.insert(
      'transactions',
      _valeurs(
        type: type,
        montant: montant,
        compteId: compteId,
        versCompteId: versCompteId,
        categorieId: categorieId,
        date: date,
        note: note,
      ),
    );
  }

  /// Modifie une opération existante.
  Future<void> modifier({
    required int id,
    required String type,
    required int montant,
    required int compteId,
    int? versCompteId,
    int? categorieId,
    required DateTime date,
    String? note,
  }) async {
    _verifier(
      type: type,
      montant: montant,
      compteId: compteId,
      versCompteId: versCompteId,
    );
    final db = await AppDatabase.instance.database;
    await db.update(
      'transactions',
      _valeurs(
        type: type,
        montant: montant,
        compteId: compteId,
        versCompteId: versCompteId,
        categorieId: categorieId,
        date: date,
        note: note,
      ),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Supprime une opération.
  Future<void> supprimer(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  /// Liste des opérations, de la plus récente à la plus ancienne.
  Future<List<TransactionItem>> lister({
    String recherche = '',
    int? compteId,
    int? categorieId,
    DateTime? debut,
    DateTime? fin,
  }) async {
    final db = await AppDatabase.instance.database;
    final conditions = <String>[];
    final args = <Object?>[];

    final q = recherche.trim();
    if (q.isNotEmpty) {
      conditions.add(
        '(t.note LIKE ? OR c.name LIKE ? OR a.name LIKE ? OR b.name LIKE ?)',
      );
      args.addAll(List.filled(4, '%$q%'));
    }
    if (compteId != null) {
      conditions.add('(t.account_id = ? OR t.to_account_id = ?)');
      args.add(compteId);
      args.add(compteId);
    }
    if (categorieId != null) {
      conditions.add('t.category_id = ?');
      args.add(categorieId);
    }
    if (debut != null) {
      conditions.add('t.date >= ?');
      args.add(_iso(debut));
    }
    if (fin != null) {
      conditions.add('t.date <= ?');
      args.add(_iso(fin));
    }
    final where =
        conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';

    final rows = await db.rawQuery('''
      SELECT t.*, a.name AS account_name, b.name AS to_account_name,
             c.name AS category_name
      FROM transactions t
      JOIN accounts a ON a.id = t.account_id
      LEFT JOIN accounts b ON b.id = t.to_account_id
      LEFT JOIN categories c ON c.id = t.category_id
      $where
      ORDER BY t.date DESC, t.id DESC
    ''', args);

    return rows
        .map(
          (r) => TransactionItem(
            id: r['id'] as int,
            type: r['type'] as String,
            amount: (r['amount'] as num).toInt(),
            accountId: r['account_id'] as int,
            accountName: r['account_name'] as String,
            toAccountId: r['to_account_id'] as int?,
            toAccountName: r['to_account_name'] as String?,
            categoryId: r['category_id'] as int?,
            categoryName: r['category_name'] as String?,
            date: DateTime.parse(r['date'] as String),
            note: r['note'] as String?,
          ),
        )
        .toList();
  }
}