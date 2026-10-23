import 'dart:convert';
import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

/// Ce que contient un fichier de sauvegarde (affiché avant restauration).
class BackupSummary {
  const BackupSummary({
    required this.accounts,
    required this.categories,
    required this.budgets,
    required this.transactions,
    this.date,
  });

  final int accounts;
  final int categories;
  final int budgets;
  final int transactions;
  final DateTime? date;
}

/// Sauvegarde et restauration des données (section 11 de la fiche).
///
/// La sauvegarde est un fichier .json qui contient les comptes, les
/// catégories, les budgets et les opérations. Le code PIN ou le mot de
/// passe n'en fait pas partie : il reste dans le stockage sécurisé.
class BackupService {
  BackupService._();
  static final BackupService instance = BackupService._();

  static const _application = 'gestion_argent';
  static const _version = 1;
  static const _cleDerniere = 'derniere_sauvegarde';

  /// Tables sauvegardées, dans l'ordre où on peut les recréer
  /// (les comptes et catégories avant les opérations et budgets).
  static const _colonnes = <String, List<String>>{
    'accounts': ['id', 'name', 'type', 'initial_balance'],
    'categories': ['id', 'name', 'type', 'is_default'],
    'budgets': ['id', 'category_id', 'month', 'amount'],
    'transactions': [
      'id',
      'type',
      'amount',
      'account_id',
      'to_account_id',
      'category_id',
      'date',
      'note',
    ],
  };

  String _deuxChiffres(int n) => n.toString().padLeft(2, '0');

  /// Ex. : gestion_argent_sauvegarde_2026-10-23.json
  String nomFichier() {
    final d = DateTime.now();
    return 'gestion_argent_sauvegarde_'
        '${d.year}-${_deuxChiffres(d.month)}-${_deuxChiffres(d.day)}.json';
  }

  /// Crée le contenu du fichier de sauvegarde.
  Future<Uint8List> exporter() async {
    final db = await AppDatabase.instance.database;
    final contenu = <String, Object?>{
      'application': _application,
      'version': _version,
      'date': DateTime.now().toIso8601String(),
    };
    for (final table in _colonnes.keys) {
      contenu[table] = await db.query(table, orderBy: 'id');
    }
    final texte = const JsonEncoder.withIndent('  ').convert(contenu);
    return Uint8List.fromList(utf8.encode(texte));
  }

  /// Lit et vérifie un fichier de sauvegarde.
  /// Lève une ArgumentError s'il n'est pas valide.
  (Map<String, List<Map<String, Object?>>>, DateTime?) _lire(Uint8List octets) {
    Object? brut;
    try {
      brut = jsonDecode(utf8.decode(octets));
    } catch (_) {
      throw ArgumentError("Ce fichier n'est pas une sauvegarde valide.");
    }
    if (brut is! Map || brut['application'] != _application) {
      throw ArgumentError(
        "Ce fichier n'est pas une sauvegarde de Gestion d'argent.",
      );
    }
    final version = brut['version'];
    if (version is! int || version > _version) {
      throw ArgumentError(
        "Cette sauvegarde vient d'une version plus récente de l'application.",
      );
    }

    final tables = <String, List<Map<String, Object?>>>{};
    for (final table in _colonnes.keys) {
      final lignes = brut[table];
      if (lignes is! List) {
        throw ArgumentError('Sauvegarde incomplète : « $table » est absent.');
      }
      final liste = <Map<String, Object?>>[];
      for (final ligne in lignes) {
        if (ligne is! Map) throw ArgumentError('Sauvegarde corrompue.');
        liste.add({for (final c in _colonnes[table]!) c: ligne[c]});
      }
      tables[table] = liste;
    }

    final d = brut['date'];
    return (tables, d is String ? DateTime.tryParse(d) : null);
  }

  /// Vérifie un fichier et indique ce qu'il contient, sans rien modifier.
  BackupSummary analyser(Uint8List octets) {
    final (tables, date) = _lire(octets);
    return BackupSummary(
      accounts: tables['accounts']!.length,
      categories: tables['categories']!.length,
      budgets: tables['budgets']!.length,
      transactions: tables['transactions']!.length,
      date: date,
    );
  }

  /// Remplace toutes les données par celles du fichier.
  /// Tout se fait dans une seule transaction : si une erreur survient,
  /// les données actuelles restent intactes.
  Future<void> restaurer(Uint8List octets) async {
    final (tables, _) = _lire(octets);
    final db = await AppDatabase.instance.database;
    await db.transaction((txn) async {
      for (final table in ['transactions', 'budgets', 'categories', 'accounts']) {
        await txn.delete(table);
      }
      final batch = txn.batch();
      for (final table in _colonnes.keys) {
        for (final ligne in tables[table]!) {
          batch.insert(table, ligne);
        }
      }
      await batch.commit(noResult: true);
    });
  }

  /// Mémorise la date de la dernière sauvegarde.
  Future<void> noterSauvegarde() async {
    final db = await AppDatabase.instance.database;
    await db.insert(
      'settings',
      {'key': _cleDerniere, 'value': DateTime.now().toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DateTime?> derniereSauvegarde() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'settings',
      where: '"key" = ?',
      whereArgs: [_cleDerniere],
    );
    if (rows.isEmpty) return null;
    return DateTime.tryParse(rows.first['value'] as String);
  }
}