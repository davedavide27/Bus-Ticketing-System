import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Getter for the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return await openDatabase(
      join(dbPath, 'bus_ticketing.db'),
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create tables when the database is first created
  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE license_plate (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plate_number TEXT UNIQUE
      )
    ''');
    await db.execute('''
      CREATE TABLE bus_number (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bus_number TEXT UNIQUE
      )
    ''');
    await db.execute('''
      CREATE TABLE routes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        route_name TEXT UNIQUE
      )
    ''');
  }

  // Insert or update the license plate
  Future<void> insertLicensePlate(String licensePlate) async {
    final db = await database;

    // Check if the license plate already exists
    final existingPlate = await getLicensePlate();

    // If the plate has changed or does not exist, update it
    if (existingPlate != licensePlate) {
      // Delete the existing plate
      await db.delete(
        'license_plate',
        where: 'plate_number = ?',
        whereArgs: [existingPlate],
      );

      // Insert the new plate
      await db.insert(
        'license_plate',
        {'plate_number': licensePlate},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  // Retrieve the license plate
  Future<String?> getLicensePlate() async {
    final db = await database;
    final result = await db.query('license_plate', limit: 1);
    if (result.isNotEmpty) {
      return result.first['plate_number'] as String?;
    }
    return null;
  }

  // Insert or update the bus number
  Future<void> insertBusNumber(String busNumber) async {
    final db = await database;

    // Check if the bus number already exists
    final existingBusNumber = await getBusNumber();

    // If the bus number has changed or does not exist, update it
    if (existingBusNumber != busNumber) {
      // Delete the existing bus number
      await db.delete(
        'bus_number',
        where: 'bus_number = ?',
        whereArgs: [existingBusNumber],
      );

      // Insert the new bus number
      await db.insert(
        'bus_number',
        {'bus_number': busNumber},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  // Retrieve the bus number
  Future<String?> getBusNumber() async {
    final db = await database;
    final result = await db.query('bus_number', limit: 1);
    if (result.isNotEmpty) {
      return result.first['bus_number'] as String?;
    }
    return null;
  }

  // Insert a route into the database
  Future<void> insertRoute(String routeName) async {
    final db = await database;
    await db.insert(
      'routes',
      {'route_name': routeName},
      conflictAlgorithm: ConflictAlgorithm.ignore, // Avoid duplicates
    );
  }

  // Insert multiple routes into the database
  Future<void> insertMultipleRoutes(List<String> routeNames) async {
    final db = await database;

    // Start a batch
    final batch = db.batch();

    // Add each route to the batch
    for (var route in routeNames) {
      batch.insert(
        'routes',
        {'route_name': route},
        conflictAlgorithm: ConflictAlgorithm.ignore, // Avoid duplicates
      );
    }

    // Execute the batch
    await batch.commit();
  }

  // Retrieve all routes from the database
  Future<List<String>> getRoutes() async {
    final db = await database;
    final result = await db.query('routes');
    return result.map((e) => e['route_name'] as String).toList();
  }

  // Clear all routes from the database
  Future<void> clearRoutes() async {
    final db = await database;
    await db.delete('routes');
  }

  // Delete a specific route from the database
  Future<void> deleteRoute(String routeName) async {
    final db = await database;
    await db.delete(
      'routes',
      where: 'route_name = ?',
      whereArgs: [routeName],
    );
  }
}
