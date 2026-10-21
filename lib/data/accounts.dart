import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

/// Libellé affiché pour chaque type de compte.
String libelleTypeCompte(String type) => switch (type) {
      'cash' => 'Espèces',
      'bank' => 'Banque',
      _ => 'Mobile money',
    };

class AccountDetails {
  const AccountDetails({
    required this.id,
    required this.name,
    required this.type,
    required this.initialBalance,
  });

  final int id;
  final String name;
  final String type; // 'cash', 'bank' ou 'mobile'
  final int initialBalance;
}

/// Création, modification et suppression des comptes.
class Accounts {
  Accounts._();
  static final Accounts instance = Accounts._();

  Future<AccountDetails> details(int id) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('accounts', where: 'id = ?', whereArgs: [id]);
    final r = rows.first;
    return AccountDetails(
      id: r['id'] as int,
      name: r['name'] as String,
      type: r['type'] as String,
      initialBalance: (r['initial_balance'] as num).toInt(),
    );
  }

  Future<void> _verifierNom(Database db, String nom, {int? sauf}) async {
    if (nom.trim().isEmpty) {
      throw ArgumentError('Saisissez un nom pour le compte.');
    }
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS n FROM accounts '
      'WHERE LOWER(name) = LOWER(?) AND id != ?',
      [nom.trim(), sauf ?? -1],
    );
    if ((rows.first['n'] as num).toInt() > 0) {
      throw ArgumentError('Un compte porte déjà ce nom.');
    }
  }

  Future<void> creer({
    required String nom,
    required String type,
    required int soldeInitial,
  }) async {
    final db = await AppDatabase.instance.database;
    await _verifierNom(db, nom);
    await db.insert('accounts', {
      'name': nom.trim(),
      'type': type,
      'initial_balance': soldeInitial,
    });
  }

  Future<void> modifier({
    required int id,
    required String nom,
    required String type,
    required int soldeInitial,
  }) async {
    final db = await AppDatabase.instance.database;
    await _verifierNom(db, nom, sauf: id);
    await db.update(
      'accounts',
      {
        'name': nom.trim(),
        'type': type,
        'initial_balance': soldeInitial,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Supprime un compte, seulement s'il n'a aucune opération.
  Future<void> supprimer(int id) async {
    final db = await AppDatabase.instance.database;
    final n = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM transactions '
            'WHERE account_id = ? OR to_account_id = ?',
            [id, id],
          ),
        ) ??
        0;
    if (n > 0) {
      throw ArgumentError(
        "Ce compte contient $n opération(s). "
        "Supprimez-les ou modifiez-les d'abord.",
      );
    }
    await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }
}