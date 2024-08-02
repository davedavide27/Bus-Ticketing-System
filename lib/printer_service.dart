import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'departure_setup_open.dart'; // Import the PrinterService
import 'receipt_service.dart'; // Import the ReceiptService
import 'routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool departureStarted = false; // Global departure state
  bool departureClosed = false; // Track if departure is closed

  void _startDeparture() {
    setState(() {
      departureStarted = true;
      departureClosed = false; // Reset closed state when starting
    });
  }

  void _stopDeparture() {
    setState(() {
      departureStarted = false;
      departureClosed = true; // Set departure as closed
    });
  }

  Future<bool> _onWillPop() async {
    if (departureClosed) {
      // Allow exit if departure is already closed
      return true;
    }

    // Show a confirmation dialog
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Exit'),
        content: const Text('Do you want to close the departure and exit?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _printCloseDepartureReceipt();
              Navigator.of(context).pop(true); // Exit the app
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }

  Future<void> _printCloseDepartureReceipt() async {
    final now = DateTime.now();
    final departureDate = DateFormat('MM/dd/yyyy').format(now);
    final departureTime = DateFormat('hh:mm a').format(now);

    try {
      // Print receipt specifically for closing departure
      await PrinterService.printReceipt(
        context: context,
        line: 'Departure Closed',
        departureDate: departureDate,
        departureTime: departureTime,
        busNumber: 'BUS 018',
        licensePlate: 'ABC 1234',
        openingOr: '026376',
        openingSaleDateTime: DateFormat('MM/dd/yyyy HH:mm:ss').format(DateTime.now()),
      );

      // Save the receipt details as a text file
      final receiptContent = 'Line: Departure Closed\n'
          'Departure Date: $departureDate\n'
          'Departure Time: $departureTime\n'
          'Bus Number: BUS 018\n'
          'License Plate: ABC 1234\n'
          'Opening OR: 026376\n'
          'Opening Sale DateTime: ${DateFormat('MM/dd/yyyy HH:mm:ss').format(DateTime.now())}';
      final fileName = 'departure_close_receipt_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.txt';

      await ReceiptService.saveReceipt(receiptContent, fileName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to print departure close receipt: $e')),
      );
    }
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
          departureClosed: departureClosed, // Pass closed state to WelcomePage
        ),
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  final VoidCallback onDepartureStart;
  final VoidCallback onDepartureClose;
  final bool departureStarted;
  final bool departureClosed;

  const WelcomePage({
    super.key,
    required this.onDepartureStart,
    required this.onDepartureClose,
    required this.departureStarted,
    required this.departureClosed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baltransco Ticketing System'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Handle profile action
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
                  color: Colors.grey[300], // Background color of the container
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
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DepartureSetupPage(
                      onDepartureClose: onDepartureClose,
                      departureStarted: departureStarted,
                      departureClosed: departureClosed, // Pass closed state
                    ),
                  ),
                );
                if (result != null && result) {
                  onDepartureStart(); // Update departureStarted state
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
          if (departureClosed) // Show message if departure is closed
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
  final VoidCallback onDepartureClose; // Add a callback for closing the departure
  final bool departureStarted; // Track if departure has started
  final bool departureClosed; // Track if departure is closed

  const DepartureSetupPage({
    super.key,
    required this.onDepartureClose,
    required this.departureStarted,
    required this.departureClosed,
  });

  @override
  _DepartureSetupPageState createState() => _DepartureSetupPageState();
}

class _DepartureSetupPageState extends State<DepartureSetupPage> {
  String selectedRoute = 'Bangcasi-Dumalagan to Ampayon Rotunda';
  final TextEditingController departureTimeController = TextEditingController();
  final TextEditingController licensePlateController = TextEditingController(text: 'ABC 1234');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final formattedDate = DateFormat('MM/dd/yyyy').format(now);
    final formattedTime = DateFormat('hh:mm a').format(now);
    departureTimeController.text = '$formattedDate | $formattedTime';
  }

  @override
  void dispose() {
    departureTimeController.dispose();
    licensePlateController.dispose();
    super.dispose();
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
      // Print receipt for start departure
      await PrinterService.printReceipt(
        context: context,
        line: selectedRoute,
        departureDate: departureDate,
        departureTime: departureTime,
        busNumber: 'BUS 018',
        licensePlate: licensePlateController.text,
        openingOr: '026376',
        openingSaleDateTime: DateFormat('MM/dd/yyyy HH:mm:ss').format(DateTime.now()),
      );

      // Save the receipt details as a text file
      final receiptContent = 'Line: $selectedRoute\n'
          'Departure Date: $departureDate\n'
          'Departure Time: $departureTime\n'
          'Bus Number: BUS 018\n'
          'License Plate: ${licensePlateController.text}\n'
          'Opening OR: 026376\n'
          'Opening Sale DateTime: ${DateFormat('MM/dd/yyyy HH:mm:ss').format(DateTime.now())}';
      final fileName = 'departure_start_receipt_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.txt';

      await ReceiptService.saveReceipt(receiptContent, fileName);

      // Navigate to the RoutesPage after saving the receipt
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RoutesPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to print receipt: $e')),
      );
    }
  }

  Future<void> _handleExit() async {
    if (widget.departureStarted && !widget.departureClosed) {
      final shouldCloseDeparture = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Departure Close'),
          content: const Text('Do you want to close the departure?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true); // Confirm close
              },
              child: const Text('Close Departure'),
            ),
          ],
        ),
      );

      if (shouldCloseDeparture == true) {
        widget.onDepartureClose(); // Notify parent widget
        Navigator.pop(context); // Close the DepartureSetupPage
      }
    } else {
      Navigator.pop(context); // Simply go back if departure isn't started or already closed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Departure Setup'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleExit, // Handle exit with possible departure close
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Line and Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedRoute,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedRoute = newValue!;
                  });
                },
                items: <String>[
                  'Bangcasi-Dumalagan to Ampayon Rotunda',
                  'Route 2',
                  'Route 3',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Departure Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                departureTimeController.text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'License Plate',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                licensePlateController.text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _printReceipt,
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
          ],
        ),
      ),
    );
  }
}