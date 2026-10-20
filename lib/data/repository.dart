import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

/// Un compte avec son solde actuel.
class AccountBalance {
  const AccountBalance({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
  });

  final int id;
  final String name;
  final String type;
  final int balance;
}

/// Totaux d'un mois.
class MonthTotals {
  const MonthTotals({required this.income, required this.expense});

  final int income;
  final int expense;
  int get remaining => income - expense;
}

/// Accès aux données : toutes les requêtes SQLite passent par ici.
class Repository {
  Repository._();
  static final Repository instance = Repository._();

  Future<Database> get _db => AppDatabase.instance.database;

  String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Comptes avec leur solde, calculé à partir des opérations.
  Future<List<AccountBalance>> comptes() async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT a.id, a.name, a.type,
        a.initial_balance + COALESCE(SUM(
          CASE
            WHEN t.type = 'income'   AND t.account_id = a.id    THEN t.amount
            WHEN t.type = 'expense'  AND t.account_id = a.id    THEN -t.amount
            WHEN t.type = 'transfer' AND t.account_id = a.id    THEN -t.amount
            WHEN t.type = 'transfer' AND t.to_account_id = a.id THEN t.amount
            ELSE 0
          END
        ), 0) AS balance
      FROM accounts a
      LEFT JOIN transactions t
        ON t.account_id = a.id OR t.to_account_id = a.id
      GROUP BY a.id
      ORDER BY a.id
    ''');
    return rows
        .map(
          (r) => AccountBalance(
            id: r['id'] as int,
            name: r['name'] as String,
            type: r['type'] as String,
            balance: (r['balance'] as num).toInt(),
          ),
        )
        .toList();
  }

  /// Revenus et dépenses du mois (les transferts sont ignorés).
  Future<MonthTotals> totauxDuMois(DateTime mois) async {
    final db = await _db;
    final debut = _iso(DateTime(mois.year, mois.month, 1));
    final fin = _iso(DateTime(mois.year, mois.month + 1, 1));
    final rows = await db.rawQuery('''
      SELECT type, COALESCE(SUM(amount), 0) AS total
      FROM transactions
      WHERE date >= ? AND date < ? AND type IN ('income', 'expense')
      GROUP BY type
    ''', [debut, fin]);

    var revenus = 0;
    var depenses = 0;
    for (final r in rows) {
      final total = (r['total'] as num).toInt();
      if (r['type'] == 'income') revenus = total;
      if (r['type'] == 'expense') depenses = total;
    }
    return MonthTotals(income: revenus, expense: depenses);
  }

  Future<int> _idCompte(Database db, String nom) async {
    final r = await db.query('accounts', where: 'name = ?', whereArgs: [nom]);
    return r.first['id'] as int;
  }

  Future<int> _idCategorie(Database db, String nom, String type) async {
    final r = await db.query(
      'categories',
      where: 'name = ? AND type = ?',
      whereArgs: [nom, type],
    );
    return r.first['id'] as int;
  }

  /// PROVISOIRE : charge les exemples de la fiche (sert à tester).
  /// Résultat attendu : total 1 250 000 Ar, revenus 2 000 000 Ar,
  /// dépenses 750 000 Ar.
  Future<void> chargerExemple() async {
    final db = await _db;
    final existantes = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM transactions'),
        ) ??
        0;
    if (existantes > 0) return;

    final now = DateTime.now();
    String jour(int j) => _iso(DateTime(now.year, now.month, j));

    final especes = await _idCompte(db, 'Espèces');
    final banque = await _idCompte(db, 'Banque');
    final mvola = await _idCompte(db, 'MVola');

    final salaire = await _idCategorie(db, 'Salaire', 'income');
    final commerce = await _idCategorie(db, 'Commerce', 'income');
    final alimentation = await _idCategorie(db, 'Alimentation', 'expense');
    final logement = await _idCategorie(db, 'Logement', 'expense');
    final transport = await _idCategorie(db, 'Transport', 'expense');
    final sante = await _idCategorie(db, 'Santé', 'expense');

    final batch = db.batch();
    void op(String type, int montant, int compte, int? categorie, int j,
        {int? versCompte, String? note}) {
      batch.insert('transactions', {
        'type': type,
        'amount': montant,
        'account_id': compte,
        'to_account_id': versCompte,
        'category_id': categorie,
        'date': jour(j),
        'note': note,
      });
    }

    op('income', 1500000, banque, salaire, 1, note: 'Salaire');
    op('income', 500000, especes, commerce, 3, note: 'Ventes');
    op('expense', 25000, especes, alimentation, 5, note: 'Déjeuner');
    op('expense', 400000, banque, logement, 5, note: 'Loyer');
    op('transfer', 100000, especes, null, 6,
        versCompte: mvola, note: 'Espèces vers MVola');
    op('expense', 75000, mvola, transport, 7, note: 'Transport');
    op('expense', 250000, banque, sante, 8, note: 'Pharmacie');

    await batch.commit(noResult: true);
  }

  /// PROVISOIRE : efface toutes les opérations.
  Future<void> viderOperations() async {
    final db = await _db;
    await db.delete('transactions');
  }
}