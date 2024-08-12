import 'package:flutter/material.dart';
import 'screens/menu_screen.dart'; // Import the MenuScreen
import 'departure_setup_open.dart'; // Import the DepartureSetupPage
import 'settings.dart'; // Import the SettingsPage
import 'database_helper.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool departureStarted = false;
  bool departureClosed = false;
  String licensePlate = '';
  String busNumber = ''; // Add busNumber variable
  List<String> routes = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final dbHelper = DatabaseHelper();

    // Initialize database with routes if necessary
    await _insertInitialRoutes(dbHelper);

    final plate = await dbHelper.getLicensePlate();
    final busNo = await dbHelper.getBusNumber(); // Get the bus number from the database
    final routeList = await dbHelper.getRoutes();

    setState(() {
      licensePlate = plate ?? '';
      busNumber = busNo ?? ''; // Set the bus number
      routes = routeList;
    });
  }

  Future<void> _insertInitialRoutes(DatabaseHelper dbHelper) async {
    // List of routes to insert
    final initialRoutes = [
      'BANCASI-DUMALAGAN KM 0',
      'CEMETERY KM 1',
      'BANCASI ROTUNDA KM 2',
      'IDEMI - TOYOTA KM 3',
      'LIBERTAD SPORTS COMPLEX KM 4',
      'FERNANDEZ - SALAS KM 5',
      'BUTUAN DOCTORS - DOTTIES KM 6',
      'CAILANO - DBP KM 7',
      'OCHOA KM 8',
      'ALBA - ZCC KM 9',
      'PALAWAN - J MARKETING KM 10',
      'BAAN VIADUCT - Flying V KM 11',
      'Filinvest KM 12',
      'Eastwood - Wilton KM 13',
      'Tiniwisan Crossing KM 14',
      'PHISCI - Vista Man KM 15',
      'Ampayon Rotunda KM 16',
    ];

    // Check if routes are already in the database
    final existingRoutes = await dbHelper.getRoutes();
    if (existingRoutes.isEmpty) {
      for (var route in initialRoutes) {
        await dbHelper.insertRoute(route);
      }
    }
  }

  void _startDeparture() {
    setState(() {
      departureStarted = true;
      departureClosed = false;
    });
  }

  void _stopDeparture() {
    setState(() {
      departureStarted = false;
      departureClosed = true;
    });
  }

  void _updateLicensePlate(String newLicensePlate) {
    setState(() {
      licensePlate = newLicensePlate;
      final dbHelper = DatabaseHelper();
      dbHelper.insertLicensePlate(newLicensePlate);
    });
  }

  void _updateBusNumber(String newBusNumber) {
    setState(() {
      busNumber = newBusNumber;
      final dbHelper = DatabaseHelper();
      dbHelper.insertBusNumber(newBusNumber);
    });
  }

  void _updateRoutes(List<String> newRoutes) async {
    setState(() {
      routes = newRoutes;
    });

    final dbHelper = DatabaseHelper();
    await dbHelper.clearRoutes(); // Ensure old routes are removed

    for (var route in newRoutes) {
      await dbHelper.insertRoute(route); // Insert each route individually
    }
  }

  Future<bool> _onWillPop() async {
    if (departureClosed) {
      return true;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please close the departure before exiting.')),
    );

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Ticketing System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: WillPopScope(
        onWillPop: _onWillPop,
        child: MenuScreen(
          onDepartureStart: _startDeparture,
          onDepartureClose: _stopDeparture,
          departureStarted: departureStarted,
          departureClosed: departureClosed,
          licensePlate: licensePlate,
          onLicensePlateChanged: _updateLicensePlate,
          routes: routes,
          onRoutesChanged: _updateRoutes,
        ),
      ),
      routes: {
        DepartureSetupPage.routeName: (context) => DepartureSetupPage(
          onDepartureClose: _stopDeparture,
          departureStarted: departureStarted,
          departureClosed: departureClosed,
          licensePlate: licensePlate,
          routes: routes,
        ),
        SettingsPage.routeName: (context) => SettingsPage(
          initialLicensePlate: licensePlate,
          onLicensePlateChanged: _updateLicensePlate,
          initialBusNumber: busNumber, // Pass the initial bus number
          onBusNumberChanged: _updateBusNumber, // Pass the bus number update callback
          initialRoutes: routes,
          onRoutesChanged: _updateRoutes,
        ),
      },
    );
  }
}
