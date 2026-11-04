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

/// Accès aux données : calcul des soldes et des totaux du mois.
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
}