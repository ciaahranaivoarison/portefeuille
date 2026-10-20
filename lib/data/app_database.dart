import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Base de données locale (SQLite) : tout est enregistré sur le téléphone.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _ouvrir();
    return _db!;
  }

  Future<Database> _ouvrir() async {
    final chemin = join(await getDatabasesPath(), 'gestion_argent.db');
    return openDatabase(
      chemin,
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _creer,
    );
  }

  Future<void> _creer(Database db, int version) async {
    // Comptes : Espèces, Banque, MVola, Orange Money, Airtel Money
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        initial_balance INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Catégories de dépenses et de revenus
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL CHECK (type IN ('expense', 'income')),
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Opérations : dépense, revenu ou transfert entre deux comptes
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL CHECK (type IN ('expense', 'income', 'transfer')),
        amount INTEGER NOT NULL CHECK (amount > 0),
        account_id INTEGER NOT NULL REFERENCES accounts(id),
        to_account_id INTEGER REFERENCES accounts(id),
        category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,
        date TEXT NOT NULL,
        note TEXT
      )
    ''');

    // Budgets mensuels par catégorie (month = '2026-10')
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
        month TEXT NOT NULL,
        amount INTEGER NOT NULL CHECK (amount > 0),
        UNIQUE (category_id, month)
      )
    ''');

    // Réglages (protection activée, etc.)
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await _remplirParDefaut(db);
  }

  Future<void> _remplirParDefaut(Database db) async {
    final batch = db.batch();

    const comptes = [
      ['Espèces', 'cash'],
      ['Banque', 'bank'],
      ['MVola', 'mobile'],
      ['Orange Money', 'mobile'],
      ['Airtel Money', 'mobile'],
    ];
    for (final c in comptes) {
      batch.insert('accounts', {'name': c[0], 'type': c[1]});
    }

    const depenses = [
      'Alimentation',
      'Transport',
      'Logement',
      'Santé',
      'Téléphone / Internet',
      'Loisirs',
      'Shopping',
      'Autres',
    ];
    for (final nom in depenses) {
      batch.insert(
        'categories',
        {'name': nom, 'type': 'expense', 'is_default': 1},
      );
    }

    const revenus = ['Salaire', 'Commerce', 'Freelance', 'Cadeau', 'Autres'];
    for (final nom in revenus) {
      batch.insert(
        'categories',
        {'name': nom, 'type': 'income', 'is_default': 1},
      );
    }

    await batch.commit(noResult: true);
  }

  /// Petit contrôle provisoire, affiché sur l'écran d'accueil.
  Future<String> resume() async {
    final db = await database;
    final comptes = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM accounts'),
        ) ??
        0;
    final categories = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM categories'),
        ) ??
        0;
    return 'Base de données prête : $comptes comptes, $categories catégories';
  }
}