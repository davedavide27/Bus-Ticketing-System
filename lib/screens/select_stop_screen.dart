import 'package:flutter/material.dart';
import 'bus_ticket_screen.dart'; // Import the BusTicketScreen
import '../database_helper.dart'; // Import DatabaseHelper
import '../printer_service.dart'; // Import PrinterService
import '../or_number_service.dart'; // Import ORNumberService
import 'package:intl/intl.dart';

class SelectStopScreen extends StatefulWidget {
  const SelectStopScreen({Key? key}) : super(key: key);

  @override
  _SelectStopScreenState createState() => _SelectStopScreenState();
}

class _SelectStopScreenState extends State<SelectStopScreen> {
  List<String> stops = [];
  String? selectedStop;
  bool reverseOrder = false;
  String licensePlate = '';
  String busNumber = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dbHelper = DatabaseHelper();

    // Fetch license plate and routes from the database
    final plate = await dbHelper.getLicensePlate();
    final busNum = await dbHelper
        .getBusNumber(); // Fetch the bus number from the database
    final routeList = await dbHelper.getRoutes();

    setState(() {
      licensePlate = plate ?? '';
      busNumber = busNum ?? ''; // Set the bus number
      stops = routeList.where((stop) => stop != 'Ampayon Rotunda KM 16')
          .toList(); // Filter out the stop
    });
  }

  Future<void> _saveSelectedStop() async {
    final dbHelper = DatabaseHelper();

    if (selectedStop != null) {
      await dbHelper.storeSelectedStop(
          selectedStop!); // Save selected stop to the database
    }
  }

  void _printReceipt() async {
    if (selectedStop != null && busNumber.isNotEmpty) {
      await _saveSelectedStop(); // Save selected stop before printing

      final openingOrNumber = await ORNumberService.getNextORNumber();
      final currentDateTime = DateTime.now();

      // Format the date and time with the separator
      String formattedDate = DateFormat('yyyy-MM-dd').format(currentDateTime);
      String formattedTime = DateFormat('hh:mm a').format(
          currentDateTime); // AM/PM format
      String openingSaleDateTime = '$formattedDate | $formattedTime'; // Date and Time with separator

      PrinterService.printReceipt(
        context: context,
        line: selectedStop!,
        departureDate: formattedDate,
        departureTime: formattedTime,
        busNumber: busNumber,
        // Use the entered bus number
        licensePlate: licensePlate,
        openingOr: openingOrNumber,
        openingSaleDateTime: openingSaleDateTime,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.now().toLocal().toString().split(' ')[0];
    final currentTime = TimeOfDay.now().format(context);
    final dateTimeString = '$currentDate | $currentTime';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Starting Stop'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: TextEditingController(text: dateTimeString),
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Date & Time',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 12),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: TextEditingController(text: busNumber),
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Bus Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: TextEditingController(text: licensePlate),
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'License Plate',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Starting Stop',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              value: selectedStop,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Colors.black),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedStop = newValue;
                    reverseOrder = newValue == 'Ampayon Rotunda KM 16';
                  });
                }
              },
              items: stops.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: selectedStop != null && busNumber.isNotEmpty
                    ? () {
                  _printReceipt(); // Print the receipt before navigating
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BusTicketScreen(
                            startingStop: selectedStop!,
                            reverseOrder: reverseOrder,
                          ),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 30),
                ),
                child: const Text(
                  'CONTINUE',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}