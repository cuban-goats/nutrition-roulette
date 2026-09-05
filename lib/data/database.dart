import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/food.dart';

class FoodDatabase {
  static const _databaseName = 'nutrition_roulette.db';
  static const _table = 'foods';
  static const _seedFoods = <_SeedFood>[
    _SeedFood('Pizza', 'Cheesy, oven-baked, and always a crowd pleaser.'),
    _SeedFood('Sushi', 'Fresh fish and rice. A light, satisfying option.'),
    _SeedFood('Burger', 'Juicy patty with all the toppings.'),
    _SeedFood('Pasta', 'Carbs, comfort, and your favorite sauce.'),
    _SeedFood('Salad', 'Crisp greens, crunch, and a simple dressing.'),
  ];

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), _databaseName);
    final db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT
          )
        ''');
        for (final seed in _seedFoods) {
          await db.insert(_table, seed.toMap());
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE $_table ADD COLUMN description TEXT');
        }
      },
    );
    return db;
  }

  Future<List<Food>> getFoods() async {
    final db = await database;
    final rows = await db.query(_table, orderBy: 'name');
    return rows.map(Food.fromMap).toList();
  }

  Future<int> addFood(String name, {String? description}) async {
    final db = await database;
    return db.insert(_table, {'name': name, 'description': description});
  }

  Future<int> updateFood(Food food) async {
    final db = await database;
    return db.update(
      _table,
      {'name': food.name, 'description': food.description},
      where: 'id = ?',
      whereArgs: [food.id],
    );
  }

  Future<int> deleteFood(int id) async {
    final db = await database;
    return db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}

class _SeedFood {
  const _SeedFood(this.name, this.description);

  final String name;
  final String description;

  Map<String, Object?> toMap() => {'name': name, 'description': description};
}