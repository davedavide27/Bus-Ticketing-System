import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'departure_setup_open.dart'; // Import the PrinterService
import 'receipt_service.dart'; // Import the ReceiptService
import 'routes.dart';
import 'database_helper.dart'; // Import the DatabaseHelper
import 'or_number_service.dart'; // Import the ORNumberService

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
  List<String> routes = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final dbHelper = DatabaseHelper();
    final plate = await dbHelper.getLicensePlate();
    final routeList = await dbHelper.getRoutes();
    setState(() {
      licensePlate = plate ?? '';
      routes = routeList;
    });
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

  void _updateRoutes(List<String> newRoutes) {
    setState(() {
      routes = newRoutes;
      final dbHelper = DatabaseHelper();
      // Clear existing routes and insert new ones
      dbHelper.insertRoute(newRoutes.join(','));
    });
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
        child: WelcomePage(
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
          initialRoutes: routes,
          onRoutesChanged: _updateRoutes,
        ),
        // Define other routes here if necessary
      },
    );
  }
}


class WelcomePage extends StatelessWidget {
  final VoidCallback onDepartureStart;
  final VoidCallback onDepartureClose;
  final bool departureStarted;
  final bool departureClosed;
  final String licensePlate;
  final ValueChanged<String> onLicensePlateChanged;
  final List<String> routes;
  final ValueChanged<List<String>> onRoutesChanged;

  const WelcomePage({
    super.key,
    required this.onDepartureStart,
    required this.onDepartureClose,
    required this.departureStarted,
    required this.departureClosed,
    required this.licensePlate,
    required this.onLicensePlateChanged,
    required this.routes,
    required this.onRoutesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baltransco Ticketing System'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                SettingsPage.routeName,
                arguments: {
                  'initialLicensePlate': licensePlate,
                  'initialRoutes': routes,
                },
              );
              if (result != null && result as bool) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings updated')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Welcome to the Bus Ticketing System!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
                child: Center(
                  child: Icon(
                    Icons.bus_alert,
                    size: 100,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  DepartureSetupPage.routeName,
                  arguments: {
                    'onDepartureClose': onDepartureClose,
                    'departureStarted': departureStarted,
                    'departureClosed': departureClosed,
                    'licensePlate': licensePlate,
                    'routes': routes,
                  },
                );
                if (result != null && result as bool) {
                  onDepartureStart();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Start Departure'),
            ),
          ),
          if (departureStarted && !departureClosed)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: onDepartureClose,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Close Departure'),
              ),
            ),
          if (departureClosed)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: const Text(
                'Departure has been closed.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class DepartureSetupPage extends StatefulWidget {
  static const String routeName = '/departureSetup'; // Define route name

  final VoidCallback onDepartureClose;
  final bool departureStarted;
  final bool departureClosed;
  final String licensePlate;
  final List<String> routes;

  const DepartureSetupPage({
    super.key,
    required this.onDepartureClose,
    required this.departureStarted,
    required this.departureClosed,
    required this.licensePlate,
    required this.routes,
  });

  @override
  _DepartureSetupPageState createState() => _DepartureSetupPageState();
}

class _DepartureSetupPageState extends State<DepartureSetupPage> {
  String selectedRoute = '';
  final TextEditingController departureTimeController = TextEditingController();
  final TextEditingController licensePlateController = TextEditingController();
  String orNumber = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final formattedDate = DateFormat('MM/dd/yyyy').format(now);
    final formattedTime = DateFormat('hh:mm a').format(now);
    departureTimeController.text = '$formattedDate | $formattedTime';
    licensePlateController.text = widget.licensePlate;
    selectedRoute = widget.routes.isNotEmpty ? widget.routes.first : ''; // Initialize with the first route
    _generateOrNumber(); // Generate OR number on initialization
  }

  @override
  void dispose() {
    departureTimeController.dispose();
    licensePlateController.dispose();
    super.dispose();
  }

  Future<void> _generateOrNumber() async {
    try {
      final nextOrNumber = await ORNumberService.getNextORNumber();
      setState(() {
        orNumber = nextOrNumber;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating OR number: $e')),
      );
    }
  }

  void _printReceipt() async {
    final departureDateTime = departureTimeController.text;
    if (!RegExp(r'^\d{2}/\d{2}/\d{4} \| \d{2}:\d{2} [AP]M$').hasMatch(departureDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid departure time format. Use MM/DD/YYYY | HH:MM AM/PM')),
      );
      return;
    }

    final departureDate = departureDateTime.split(' | ')[0];
    final departureTime = departureDateTime.split(' | ')[1];

    try {
      await PrinterService.printReceipt(
        context: context,
        line: selectedRoute,
        departureDate: departureDate,
        departureTime: departureTime,
        busNumber: 'BUS 018',
        licensePlate: licensePlateController.text,
        openingOr: orNumber,
        openingSaleDateTime: DateFormat('MM/dd/yyyy HH:mm:ss').format(DateTime.now()),
      );

      final receiptContent = 'Line: $selectedRoute\n'
          'Departure Date: $departureDate\n'
          'Departure Time: $departureTime\n'
          'Bus Number: BUS 018\n'
          'License Plate: ${licensePlateController.text}\n'
          'Opening OR: $orNumber\n'
          'Opening Sale DateTime: ${DateFormat('MM/dd/yyyy HH:mm:ss').format(DateTime.now())}';
      final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.txt';
      await ReceiptService.saveReceipt(receiptContent, fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt printed and saved successfully.')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => RoutesPage()),
        ModalRoute.withName('/departureSetup'),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error printing or saving receipt: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Departure Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: departureTimeController,
              decoration: const InputDecoration(
                labelText: 'Departure Date & Time',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedRoute,
              items: widget.routes.map((route) {
                return DropdownMenuItem<String>(
                  value: route,
                  child: Text(route),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRoute = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Route',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: licensePlateController,
              decoration: const InputDecoration(
                labelText: 'License Plate',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            ElevatedButton(
              onPressed: _printReceipt,
              child: const Text('Print Receipt'),
            ),
          ],
        ),
      ),
    );
  }
}


class SettingsPage extends StatefulWidget {
  static const String routeName = '/settings'; // Define route name

  final String initialLicensePlate;
  final ValueChanged<String> onLicensePlateChanged;
  final List<String> initialRoutes;
  final ValueChanged<List<String>> onRoutesChanged;

  const SettingsPage({
    super.key,
    required this.initialLicensePlate,
    required this.onLicensePlateChanged,
    required this.initialRoutes,
    required this.onRoutesChanged,
  });

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController licensePlateController = TextEditingController();
  final TextEditingController routeController = TextEditingController();
  List<String> routes = [];

  @override
  void initState() {
    super.initState();
    licensePlateController.text = widget.initialLicensePlate;
    routes = List.from(widget.initialRoutes); // Ensure the list is a copy
  }

  void _addRoute() {
    final route = routeController.text.trim();
    if (route.isNotEmpty && !routes.contains(route)) {
      setState(() {
        routes.add(route);
        routeController.clear();
      });
    }
  }

  Future<void> _saveSettings() async {
    final dbHelper = DatabaseHelper();

    // Save the license plate
    await dbHelper.insertLicensePlate(licensePlateController.text);

    // Clear existing routes and save new routes
    await dbHelper.clearRoutes(); // Ensure old routes are removed
    for (var route in routes) {
      await dbHelper.insertRoute(route); // Save each route individually
    }

    // Update the settings
    widget.onLicensePlateChanged(licensePlateController.text);
    widget.onRoutesChanged(routes);

    Navigator.pop(context, true);
  }

  void _deleteRoute(int index) async {
    final route = routes[index];
    setState(() {
      routes.removeAt(index);
    });

    final dbHelper = DatabaseHelper();
    await dbHelper.deleteRoute(route); // Remove route from database
  }

  @override
  void dispose() {
    licensePlateController.dispose();
    routeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: licensePlateController,
              decoration: const InputDecoration(
                labelText: 'License Plate',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: routeController,
              decoration: const InputDecoration(
                labelText: 'Add Route',
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: _addRoute,
              child: const Text('Add Route'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: routes.length,
                itemBuilder: (context, index) {
                  final route = routes[index];
                  return ListTile(
                    title: Text(route),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteRoute(index),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
