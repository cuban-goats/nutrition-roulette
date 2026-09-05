import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/food.dart';

class FoodDatabase {
  static const _databaseName = 'food_picker.db';
  static const _table = 'foods';
  static const _seedFoods = ['Pizza', 'Sushi', 'Burger', 'Pasta', 'Salad'];

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), _databaseName);
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
          )
        ''');
        for (final name in _seedFoods) {
          await db.insert(_table, {'name': name});
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

  Future<int> addFood(String name) async {
    final db = await database;
    return db.insert(_table, {'name': name});
  }

  Future<int> deleteFood(int id) async {
    final db = await database;
    return db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}