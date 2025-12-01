import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:eatwise2/models/food_model.dart';

/// SQLite database helper for Indonesian food data
class FoodDatabase {
  static final FoodDatabase _instance = FoodDatabase._internal();
  factory FoodDatabase() => _instance;
  FoodDatabase._internal();

  static Database? _database;

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'eatwise_foods.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE foods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        description TEXT NOT NULL,
        calories INTEGER NOT NULL,
        protein REAL NOT NULL,
        carbs REAL NOT NULL,
        fat REAL NOT NULL,
        fiber REAL NOT NULL,
        serving_size TEXT NOT NULL,
        health_benefits TEXT NOT NULL,
        ingredients TEXT NOT NULL,
        preparation_time TEXT NOT NULL,
        tips TEXT NOT NULL,
        allergens TEXT NOT NULL,
        recommended_for TEXT NOT NULL,
        image_url TEXT
      )
    ''');

    // Seed initial data from JSON
    await _seedData(db);
  }

  /// Seed database with initial food data from JSON
  Future<void> _seedData(Database db) async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/foods_data.json');
      final Map<String, dynamic> data = json.decode(response);
      final List<dynamic> foodsJson = data['foods'];

      for (var foodJson in foodsJson) {
        final food = FoodModel.fromJson(foodJson);
        await db.insert(
          'foods',
          food.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      print('✅ Database seeded with ${foodsJson.length} foods');
    } catch (e) {
      print('❌ Error seeding database: $e');
    }
  }

  /// Insert a new food
  Future<int> insertFood(FoodModel food) async {
    final db = await database;
    return await db.insert(
      'foods',
      food.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all foods
  Future<List<FoodModel>> getAllFoods() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('foods');

    return List.generate(maps.length, (i) {
      return FoodModel.fromMap(maps[i]);
    });
  }

  /// Get food by ID
  Future<FoodModel?> getFoodById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'foods',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return FoodModel.fromMap(maps.first);
  }

  /// Get food by name (exact match)
  Future<FoodModel?> getFoodByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'foods',
      where: 'LOWER(name) = LOWER(?)',
      whereArgs: [name],
    );

    if (maps.isEmpty) return null;
    return FoodModel.fromMap(maps.first);
  }

  /// Search foods by name (partial match)
  Future<List<FoodModel>> searchFoods(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'foods',
      where: 'LOWER(name) LIKE LOWER(?)',
      whereArgs: ['%$query%'],
    );

    return List.generate(maps.length, (i) {
      return FoodModel.fromMap(maps[i]);
    });
  }

  /// Get foods by calorie range
  Future<List<FoodModel>> getFoodsByCalorieRange(int minCal, int maxCal) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'foods',
      where: 'calories BETWEEN ? AND ?',
      whereArgs: [minCal, maxCal],
    );

    return List.generate(maps.length, (i) {
      return FoodModel.fromMap(maps[i]);
    });
  }

  /// Get high protein foods (>20g protein per serving)
  Future<List<FoodModel>> getHighProteinFoods() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'foods',
      where: 'protein >= ?',
      whereArgs: [20.0],
      orderBy: 'protein DESC',
    );

    return List.generate(maps.length, (i) {
      return FoodModel.fromMap(maps[i]);
    });
  }

  /// Get low calorie foods (<400 cal per serving)
  Future<List<FoodModel>> getLowCalorieFoods() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'foods',
      where: 'calories < ?',
      whereArgs: [400],
      orderBy: 'calories ASC',
    );

    return List.generate(maps.length, (i) {
      return FoodModel.fromMap(maps[i]);
    });
  }

  /// Update a food
  Future<int> updateFood(FoodModel food) async {
    final db = await database;
    return await db.update(
      'foods',
      food.toMap(),
      where: 'id = ?',
      whereArgs: [food.id],
    );
  }

  /// Delete a food
  Future<int> deleteFood(int id) async {
    final db = await database;
    return await db.delete(
      'foods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all foods (for testing)
  Future<int> deleteAllFoods() async {
    final db = await database;
    return await db.delete('foods');
  }

  /// Get total number of foods
  Future<int> getFoodCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM foods');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Reseed database (delete all and reload from JSON)
  Future<void> reseedDatabase() async {
    final db = await database;
    await db.delete('foods');
    await _seedData(db);
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
