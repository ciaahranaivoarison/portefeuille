import 'app_database.dart';

/// Total des dépenses d'une catégorie sur la période.
class CategoryTotal {
  const CategoryTotal({required this.name, required this.amount});

  final String name;
  final int amount;
}

/// Une barre du graphique d'évolution : un jour, ou un mois.
class EvolutionPoint {
  const EvolutionPoint({required this.date, required this.amount});

  final DateTime date;
  final int amount;
}

/// Tout ce qu'affiche l'écran Statistiques pour une période.
class PeriodStats {
  const PeriodStats({
    required this.income,
    required this.expense,
    required this.categories,
    required this.points,
    required this.monthly,
  });

  final int income;
  final int expense;
  final List<CategoryTotal> categories;
  final List<EvolutionPoint> points;
  final bool monthly; // true : une barre par mois, false : une par jour

  int get balance => income - expense;
}

class Stats {
  Stats._();
  static final Stats instance = Stats._();

  String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  String _cleMois(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}';

  /// Statistiques entre deux dates (incluses). Les transferts sont ignorés.
  Future<PeriodStats> pour(DateTime debut, DateTime fin) async {
    final db = await AppDatabase.instance.database;
    final d = _iso(debut);
    final f = _iso(fin);

    // Revenus et dépenses de la période
    final totaux = await db.rawQuery('''
      SELECT type, COALESCE(SUM(amount), 0) AS total
      FROM transactions
      WHERE date >= ? AND date <= ? AND type IN ('income', 'expense')
      GROUP BY type
    ''', [d, f]);

    var revenus = 0;
    var depenses = 0;
    for (final r in totaux) {
      final total = (r['total'] as num).toInt();
      if (r['type'] == 'income') revenus = total;
      if (r['type'] == 'expense') depenses = total;
    }

    // Dépenses par catégorie
    final cats = await db.rawQuery('''
      SELECT COALESCE(c.name, 'Sans catégorie') AS name,
             SUM(t.amount) AS total
      FROM transactions t
      LEFT JOIN categories c ON c.id = t.category_id
      WHERE t.type = 'expense' AND t.date >= ? AND t.date <= ?
      GROUP BY t.category_id
      ORDER BY total DESC
    ''', [d, f]);

    final categories = cats
        .map(
          (r) => CategoryTotal(
            name: r['name'] as String,
            amount: (r['total'] as num).toInt(),
          ),
        )
        .toList();

    // Évolution : par jour (31 jours ou moins), sinon par mois
    final jours = fin.difference(debut).inDays + 1;
    final mensuel = jours > 31;

    final rows = await db.rawQuery(
      mensuel
          ? '''
            SELECT substr(date, 1, 7) AS cle, SUM(amount) AS total
            FROM transactions
            WHERE type = 'expense' AND date >= ? AND date <= ?
            GROUP BY cle
          '''
          : '''
            SELECT date AS cle, SUM(amount) AS total
            FROM transactions
            WHERE type = 'expense' AND date >= ? AND date <= ?
            GROUP BY date
          ''',
      [d, f],
    );
    final parCle = {
      for (final r in rows) r['cle'] as String: (r['total'] as num).toInt(),
    };

    final points = <EvolutionPoint>[];
    if (mensuel) {
      var m = DateTime(debut.year, debut.month, 1);
      final dernier = DateTime(fin.year, fin.month, 1);
      while (!m.isAfter(dernier)) {
        points.add(EvolutionPoint(date: m, amount: parCle[_cleMois(m)] ?? 0));
        m = DateTime(m.year, m.month + 1, 1);
      }
    } else {
      var j = DateTime(debut.year, debut.month, debut.day);
      while (!j.isAfter(fin)) {
        points.add(EvolutionPoint(date: j, amount: parCle[_iso(j)] ?? 0));
        j = DateTime(j.year, j.month, j.day + 1);
      }
    }

    final visibles = (mensuel && points.length > 24)
        ? points.sublist(points.length - 24)
        : points;

    return PeriodStats(
      income: revenus,
      expense: depenses,
      categories: categories,
      points: visibles,
      monthly: mensuel,
    );
  }
}