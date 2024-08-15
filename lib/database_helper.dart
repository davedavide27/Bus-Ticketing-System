import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart'; // Import for date formatting

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
    await db.execute('''
      CREATE TABLE tickets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        issued_at TEXT,
        starting_stop TEXT,
        destination_stop TEXT,
        fare REAL,
        is_discounted INTEGER DEFAULT 0,
        bus_or_number TEXT,
        is_cancelled INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE selected_stop (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stop_name TEXT UNIQUE
      )
    ''');
    await db.execute('''
      CREATE TABLE departures (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time TEXT,
        end_time TEXT,
        license_plate TEXT,
        route TEXT,
        is_open INTEGER DEFAULT 1
      )
    ''');
  }

  // Insert or update the license plate
  Future<void> insertLicensePlate(String licensePlate) async {
    final db = await database;
    await db.delete('license_plate');
    await db.insert(
      'license_plate',
      {'plate_number': licensePlate},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
    await db.delete('bus_number');
    await db.insert(
      'bus_number',
      {'bus_number': busNumber},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
    final batch = db.batch();
    for (var route in routeNames) {
      batch.insert(
        'routes',
        {'route_name': route},
        conflictAlgorithm: ConflictAlgorithm.ignore, // Avoid duplicates
      );
    }
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

  // Insert a ticket into the database
  Future<void> insertTicket({
    required DateTime issuedAt,
    required String startingStop,
    required String destinationStop,
    required double fare,
    bool isDiscounted = false,
    required String busOrNumber,
    bool isCancelled = false,
  }) async {
    final db = await database;
    await db.insert(
      'tickets',
      {
        'issued_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(issuedAt),
        'starting_stop': startingStop,
        'destination_stop': destinationStop,
        'fare': fare,
        'is_discounted': isDiscounted ? 1 : 0,
        'bus_or_number': busOrNumber,
        'is_cancelled': isCancelled ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve a ticket by its ID
  Future<Map<String, dynamic>?> getTicket(int ticketId) async {
    final db = await database;
    final result = await db.query(
      'tickets',
      where: 'id = ?',
      whereArgs: [ticketId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Retrieve all tickets
  Future<List<Map<String, dynamic>>> getAllTickets() async {
    final db = await database;
    final result = await db.query('tickets');
    return result;
  }

  // Retrieve tickets for today
  Future<List<Map<String, dynamic>>> getTicketsForToday() async {
    final db = await database;
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final result = await db.query(
      'tickets',
      where: 'DATE(issued_at) = ?',
      whereArgs: [today],
    );
    return result;
  }

  // Update a ticket's cancellation status
  Future<void> updateTicketCancellation(int ticketId, bool isCancelled) async {
    final db = await database;
    await db.update(
      'tickets',
      {'is_cancelled': isCancelled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [ticketId],
    );
  }

  // Delete a ticket by its ID
  Future<void> deleteTicket(int ticketId) async {
    final db = await database;
    await db.delete(
      'tickets',
      where: 'id = ?',
      whereArgs: [ticketId],
    );
  }

  // Insert or update the selected stop
  Future<void> storeSelectedStop(String stopName) async {
    final db = await database;
    await db.delete('selected_stop');
    await db.insert(
      'selected_stop',
      {'stop_name': stopName},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve the selected stop
  Future<String?> getSelectedStop() async {
    final db = await database;
    final result = await db.query('selected_stop', limit: 1);
    if (result.isNotEmpty) {
      return result.first['stop_name'] as String?;
    }
    return null;
  }

  // Delete the selected stop
  Future<void> deleteSelectedStop() async {
    final db = await database;
    await db.delete('selected_stop');
  }

  Future<bool> hasOpenDeparture() async {
    final db = await database;
    final result = await db.query(
      'selected_stop',
      where: 'end_time IS NULL',
      limit: 1,
    );
    return result.isNotEmpty;
  }


  // Start a new departure
  Future<void> startDeparture({
    required DateTime startTime,
    required String licensePlate,
    required String route,
  }) async {
    final db = await database;
    await db.insert(
      'departures',
      {
        'start_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(startTime),
        'license_plate': licensePlate,
        'route': route,
        'is_open': 1, // Mark as open
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Close an open departure
  Future<void> closeDeparture() async {
    final db = await database;
    await db.update(
      'departures',
      {
        'end_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        'is_open': 0, // Mark as closed
      },
      where: 'is_open = ?',
      whereArgs: [1],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve the most recent open departure
  Future<Map<String, dynamic>?> getOpenDeparture() async {
    final db = await database;
    final result = await db.query(
      'departures',
      where: 'is_open = ?',
      whereArgs: [1], // Open departures
      orderBy: 'start_time DESC',
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }
}
